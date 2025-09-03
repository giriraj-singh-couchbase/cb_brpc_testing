#!/bin/bash

# brpc with Couchbase Integration - Dependency Setup Script
# This script automatically sets up dependencies for both macOS and Linux

set -e  # Exit on any error

echo "🚀 Setting up brpc with Couchbase integration dependencies..."

# Detect the operating system
if [[ "$OSTYPE" == "darwin"* ]]; then
    PLATFORM="macos"
    echo "📱 Detected macOS"
elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
    PLATFORM="linux"
    echo "🐧 Detected Linux"
else
    echo "❌ Unsupported operating system: $OSTYPE"
    exit 1
fi

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# macOS setup
setup_macos() {
    echo "🍺 Setting up dependencies for macOS..."
    
    # Check if Homebrew is installed
    if ! command_exists brew; then
        echo "📦 Installing Homebrew..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    else
        echo "✅ Homebrew already installed"
    fi
    
    # Install Bazel
    if ! command_exists bazel; then
        echo "🔨 Installing Bazel..."
        brew install bazel
    else
        echo "✅ Bazel already installed"
    fi
    
    # Check Bazel version and install correct version if needed
    BAZEL_VERSION=$(bazel version 2>/dev/null | grep "Build label" | cut -d' ' -f3 || echo "unknown")
    if [[ "$BAZEL_VERSION" != "7.2.1" ]]; then
        echo "📥 Installing correct Bazel version (7.2.1)..."
        BAZEL_PATH="$(brew --prefix)/Cellar/bazel/$(brew list --versions bazel | cut -d' ' -f2)/libexec/bin"
        cd "$BAZEL_PATH"
        curl -fLO https://releases.bazel.build/7.2.1/release/bazel-7.2.1-darwin-arm64
        chmod +x bazel-7.2.1-darwin-arm64
        cd - > /dev/null
    else
        echo "✅ Correct Bazel version already installed"
    fi
    
    # Install Couchbase C++ client
    if ! brew list couchbase-cxx-client >/dev/null 2>&1; then
        echo "🗄️ Installing Couchbase C++ client..."
        brew tap couchbaselabs/homebrew-couchbase
        brew install couchbase-cxx-client
    else
        echo "✅ Couchbase C++ client already installed"
    fi
    
    # Install fmt library
    if ! brew list fmt >/dev/null 2>&1; then
        echo "📝 Installing fmt library..."
        brew install fmt
    else
        echo "✅ fmt library already installed"
    fi
    
    # Install additional dependencies
    if ! brew list pegtl >/dev/null 2>&1; then
        echo "🔧 Installing PEGTL..."
        brew install pegtl
    else
        echo "✅ PEGTL already installed"
    fi
}

# Linux setup
setup_linux() {
    echo "🐧 Setting up dependencies for Linux..."
    
    # Detect Linux distribution
    if command_exists apt-get; then
        PKG_MANAGER="apt"
        INSTALL_CMD="sudo apt-get update && sudo apt-get install -y"
        BAZEL_REPO_SETUP="curl -fsSL https://bazel.build/bazel-release.pub.gpg | gpg --dearmor > bazel.gpg && sudo mv bazel.gpg /etc/apt/trusted.gpg.d/ && echo 'deb [arch=amd64] https://storage.googleapis.com/bazel-apt stable jdk1.8' | sudo tee /etc/apt/sources.list.d/bazel.list"
    elif command_exists yum; then
        PKG_MANAGER="yum"
        INSTALL_CMD="sudo yum install -y"
        BAZEL_REPO_SETUP="sudo yum install -y dnf-plugins-core && sudo yum config-manager --add-repo https://copr.fedorainfracloud.org/coprs/vbatts/bazel/repo/epel-7/vbatts-bazel-epel-7.repo"
    elif command_exists dnf; then
        PKG_MANAGER="dnf"
        INSTALL_CMD="sudo dnf install -y"
        BAZEL_REPO_SETUP="sudo dnf install -y dnf-plugins-core"
    else
        echo "❌ Unsupported Linux distribution. Please install dependencies manually."
        exit 1
    fi
    
    echo "📦 Detected package manager: $PKG_MANAGER"
    
    # Install Bazel
    if ! command_exists bazel; then
        echo "🔨 Installing Bazel..."
        if [[ "$PKG_MANAGER" == "apt" ]]; then
            eval "$BAZEL_REPO_SETUP"
            sudo apt-get update
            sudo apt-get install -y bazel
        elif [[ "$PKG_MANAGER" == "dnf" ]]; then
            eval "$BAZEL_REPO_SETUP"
            sudo dnf install -y bazel4
        else
            eval "$BAZEL_REPO_SETUP"
            sudo yum install -y bazel
        fi
    else
        echo "✅ Bazel already installed"
    fi
    
    # Install development tools
    echo "🛠️ Installing development tools..."
    if [[ "$PKG_MANAGER" == "apt" ]]; then
        eval "$INSTALL_CMD build-essential cmake libssl-dev"
    else
        eval "$INSTALL_CMD gcc gcc-c++ make cmake openssl-devel"
    fi
    
    # Install fmt library
    echo "📝 Installing fmt library..."
    if [[ "$PKG_MANAGER" == "apt" ]]; then
        eval "$INSTALL_CMD libfmt-dev"
    else
        eval "$INSTALL_CMD fmt-devel"
    fi
    
    # Install PEGTL
    echo "🔧 Installing PEGTL..."
    if [[ "$PKG_MANAGER" == "apt" ]]; then
        eval "$INSTALL_CMD libpegtl-dev"
    else
        eval "$INSTALL_CMD pegtl-devel"
    fi
    
    # Install Couchbase C++ client
    echo "🗄️ Installing Couchbase C++ client..."
    if [[ ! -f "/usr/local/include/couchbase/cluster.hxx" ]]; then
        echo "📥 Downloading Couchbase C++ client..."
        wget -q https://packages.couchbase.com/clients/cxx/couchbase-cxx-client_1.0.0-linux_amd64.tar.gz
        tar -xzf couchbase-cxx-client_1.0.0-linux_amd64.tar.gz
        sudo cp -r couchbase-cxx-client_1.0.0-linux_amd64/include/* /usr/local/include/
        sudo cp -r couchbase-cxx-client_1.0.0-linux_amd64/lib/* /usr/local/lib/
        sudo ldconfig
        rm -rf couchbase-cxx-client_1.0.0-linux_amd64*
    else
        echo "✅ Couchbase C++ client already installed"
    fi
}

# Create symlinks function
create_symlinks() {
    echo "🔗 Creating symlinks for dependencies..."
    
    # Create third_party directory
    mkdir -p third_party
    
    if [[ "$PLATFORM" == "macos" ]]; then
        # macOS symlinks
        if [[ ! -L "third_party/couchbase" ]]; then
            ln -sf /opt/homebrew/opt/couchbase-cxx-client/include/couchbase third_party/
            echo "✅ Created Couchbase symlink (macOS)"
        fi
        
        if [[ ! -L "third_party/tao" ]]; then
            ln -sf /opt/homebrew/opt/couchbase-cxx-client/include/tao third_party/
            echo "✅ Created tao symlink (macOS)"
        fi
        
        if [[ ! -d "third_party/fmt" ]] || [[ -z "$(ls -A third_party/fmt 2>/dev/null)" ]]; then
            mkdir -p third_party/fmt
            ln -sf /opt/homebrew/opt/fmt/include/fmt/* third_party/fmt/ 2>/dev/null || true
            echo "✅ Created fmt symlinks (macOS)"
        fi
    else
        # Linux symlinks
        if [[ ! -L "third_party/couchbase" ]]; then
            ln -sf /usr/include/couchbase-cxx-client third_party/
            echo "✅ Created Couchbase symlink (Linux)"
        fi
        
        if [[ ! -L "third_party/tao" ]]; then
            ln -sf /usr/local/include/tao third_party/
            echo "✅ Created tao symlink (Linux)"
        fi
        
        if [[ ! -d "third_party/fmt" ]] || [[ -z "$(ls -A third_party/fmt 2>/dev/null)" ]]; then
            mkdir -p third_party/fmt
            # Try different possible locations for fmt headers
            if [[ -d "/usr/include/fmt" ]]; then
                ln -sf /usr/include/fmt/* third_party/fmt/ 2>/dev/null || true
            elif [[ -d "/usr/local/include/fmt" ]]; then
                ln -sf /usr/local/include/fmt/* third_party/fmt/ 2>/dev/null || true
            fi
            echo "✅ Created fmt symlinks (Linux)"
        fi
    fi
}

# Verify installation function
verify_installation() {
    echo "🔍 Verifying installation..."
    
    # Check Bazel
    if command_exists bazel; then
        echo "✅ Bazel: $(bazel version 2>/dev/null | grep "Build label" | cut -d' ' -f3 || echo "installed")"
    else
        echo "❌ Bazel not found"
        return 1
    fi
    
    # Check symlinks
    if [[ -L "third_party/couchbase" ]] && [[ -e "third_party/couchbase/cluster.hxx" ]]; then
        echo "✅ Couchbase headers accessible"
    else
        echo "❌ Couchbase headers not accessible"
        return 1
    fi
    
    if [[ -d "third_party/fmt" ]] && [[ -e "third_party/fmt/format.h" ]]; then
        echo "✅ fmt headers accessible"
    else
        echo "❌ fmt headers not accessible"
        return 1
    fi
    
    echo "🎉 All dependencies verified successfully!"
}

# Main execution
main() {
    case $PLATFORM in
        "macos")
            setup_macos
            ;;
        "linux")
            setup_linux
            ;;
    esac
    
    create_symlinks
    verify_installation
    
    echo ""
    echo "🎉 Setup complete! You can now build the project with:"
    echo "   bazel build //:brpc"
    echo ""
    echo "📚 For more information, see BUILD_SETUP_GUIDE.md"
}

# Run main function
main "$@"
