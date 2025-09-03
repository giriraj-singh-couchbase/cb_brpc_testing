# brpc with Couchbase Integration - Build Setup Guide

This guide provides step-by-step instructions to build the brpc project with Couchbase integration support on both macOS and Linux.

## 🚀 Quick Start (Automated Setup)

For a fully automated setup, use the provided script:

```bash
# Clone the project
git clone <your-repo-url>
cd cb_brpc_testing

# Run the automated setup script
./setup_dependencies.sh

# Build the project
bazel build //:brpc
```

The script will automatically:
- ✅ Detect your operating system (macOS/Linux)
- ✅ Install all required dependencies
- ✅ Create necessary symlinks
- ✅ Verify the installation
- ✅ Use the cross-platform BUILD.bazel configuration

## 📖 Manual Setup Instructions

If you prefer to set up dependencies manually, follow the detailed instructions below:

## Prerequisites

### Common Requirements
- Git
- A C++17 compatible compiler (GCC 7+ or Clang 6+)
- CMake 3.12+ (optional, for CMake builds)

### Platform-Specific Package Managers
- **macOS**: Homebrew
- **Linux**: apt (Ubuntu/Debian) or yum/dnf (RHEL/CentOS/Fedora)

## Installation Steps

### 1. Install Bazel Build Tool

#### macOS (using Homebrew)
```bash
# Install Homebrew if not already installed
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Install Bazel
brew install bazel

# The project requires Bazel 7.2.1, but Homebrew installs the latest version
# Download the correct version as suggested by the build system
cd "$(brew --prefix)/Cellar/bazel/$(brew list --versions bazel | cut -d' ' -f2)/libexec/bin"
curl -fLO https://releases.bazel.build/7.2.1/release/bazel-7.2.1-darwin-arm64
chmod +x bazel-7.2.1-darwin-arm64
cd -

# Verify Bazel version
bazel version
```

#### Linux (Ubuntu/Debian)
```bash
# Install required packages
sudo apt update
sudo apt install apt-transport-https curl gnupg

# Add Bazel repository
curl -fsSL https://bazel.build/bazel-release.pub.gpg | gpg --dearmor > bazel.gpg
sudo mv bazel.gpg /etc/apt/trusted.gpg.d/
echo "deb [arch=amd64] https://storage.googleapis.com/bazel-apt stable jdk1.8" | sudo tee /etc/apt/sources.list.d/bazel.list

# Install Bazel
sudo apt update
sudo apt install bazel

# Verify installation
bazel version
```

#### Linux (RHEL/CentOS/Fedora)
```bash
# Install required packages
sudo dnf install dnf-plugins-core

# Add Bazel repository
sudo dnf config-manager --add-repo https://copr.fedorainfracloud.org/coprs/vbatts/bazel/repo/epel-7/vbatts-bazel-epel-7.repo

# Install Bazel
sudo dnf install bazel4

# Verify installation
bazel version
```

### 2. Install Couchbase C++ Client SDK

#### macOS (using Homebrew)
```bash
# Add Couchbase repository
brew tap couchbaselabs/homebrew-couchbase

# Install Couchbase C++ client
brew install couchbase-cxx-client

# Verify installation
brew --prefix couchbase-cxx-client
ls -la $(brew --prefix couchbase-cxx-client)/include/couchbase/
```

#### Linux (Ubuntu/Debian)
```bash
# Download and install Couchbase C++ client
wget https://packages.couchbase.com/clients/cxx/couchbase-cxx-client_1.0.0-linux_amd64.tar.gz
tar -xzf couchbase-cxx-client_1.0.0-linux_amd64.tar.gz
sudo cp -r couchbase-cxx-client_1.0.0-linux_amd64/include/* /usr/local/include/
sudo cp -r couchbase-cxx-client_1.0.0-linux_amd64/lib/* /usr/local/lib/
sudo ldconfig

# Alternative: Build from source
git clone https://github.com/couchbaselabs/couchbase-cxx-client.git
cd couchbase-cxx-client
mkdir build && cd build
cmake -DCMAKE_BUILD_TYPE=Release ..
make -j$(nproc)
sudo make install
```

#### Linux (RHEL/CentOS/Fedora)
```bash
# Install development tools
sudo dnf groupinstall "Development Tools"
sudo dnf install cmake openssl-devel

# Download and install Couchbase C++ client
wget https://packages.couchbase.com/clients/cxx/couchbase-cxx-client_1.0.0-linux_amd64.tar.gz
tar -xzf couchbase-cxx-client_1.0.0-linux_amd64.tar.gz
sudo cp -r couchbase-cxx-client_1.0.0-linux_amd64/include/* /usr/local/include/
sudo cp -r couchbase-cxx-client_1.0.0-linux_amd64/lib/* /usr/local/lib/
sudo ldconfig
```

### 3. Install fmt Library

#### macOS (using Homebrew)
```bash
brew install fmt
```

#### Linux (Ubuntu/Debian)
```bash
sudo apt install libfmt-dev
```

#### Linux (RHEL/CentOS/Fedora)
```bash
sudo dnf install fmt-devel
```

### 4. Install Additional Dependencies

#### macOS (using Homebrew)
```bash
# Install additional dependencies
brew install pegtl
```

#### Linux (Ubuntu/Debian)
```bash
sudo apt install libpegtl-dev
```

#### Linux (RHEL/CentOS/Fedora)
```bash
sudo dnf install pegtl-devel
```

## Project Configuration

### 1. Clone the Project
```bash
git clone <your-repo-url>
cd cb_brpc_testing
```

### 2. Create Symlinks for Dependencies

#### macOS
```bash
# Create third_party directory structure
mkdir -p third_party

# Create symlinks for Couchbase headers
ln -sf /opt/homebrew/opt/couchbase-cxx-client/include/couchbase third_party/
ln -sf /opt/homebrew/opt/couchbase-cxx-client/include/tao third_party/

# Create symlinks for fmt headers
mkdir -p third_party/fmt
ln -sf /opt/homebrew/opt/fmt/include/fmt/* third_party/fmt/
```

#### Linux
```bash
# Create third_party directory structure
mkdir -p third_party

# Create symlinks for Couchbase headers (adjust paths based on installation)
ln -sf /usr/local/include/couchbase third_party/
ln -sf /usr/local/include/tao third_party/

# Create symlinks for fmt headers
mkdir -p third_party/fmt
ln -sf /usr/include/fmt/* third_party/fmt/ 2>/dev/null || ln -sf /usr/local/include/fmt/* third_party/fmt/
```

### 3. Fix WORKSPACE File for macOS Compatibility

#### macOS Only - Fix sed Command Syntax
```bash
# Update the WORKSPACE file to use macOS-compatible sed syntax
sed -i '' 's/sed -i protobuf\.bzl -re/sed -i '\'''\'' -e/' WORKSPACE
```

The WORKSPACE file should contain:
```starlark
patch_cmds = [
    "sed -i '' -e '4d' -e '417,508d' protobuf.bzl",
],
```

### 4. Verify BUILD.bazel Configuration

Ensure your `BUILD.bazel` file contains the following configurations:

#### Cross-Platform Couchbase and fmt Library Definitions
```starlark
# Couchbase C++ client library (cross-platform)
cc_library(
    name = "couchbase_headers",
    hdrs = glob([
        "third_party/couchbase/**/*.hxx",
        "third_party/couchbase/**/*.h",
        "third_party/tao/**/*.hpp",
    ]),
    includes = ["third_party"],
    linkopts = select({
        "@platforms//os:macos": [
            "-L/opt/homebrew/opt/couchbase-cxx-client/lib",
            "-lcouchbase_cxx_client",
        ],
        "@platforms//os:linux": [
            "-L/usr/local/lib",
            "-L/usr/lib/x86_64-linux-gnu",
            "-lcouchbase_cxx_client",
        ],
        "//conditions:default": [
            "-L/usr/local/lib",
            "-lcouchbase_cxx_client",
        ],
    }),
    visibility = ["//visibility:public"],
)

# fmt library (cross-platform)
cc_library(
    name = "fmt_headers",
    hdrs = glob(["third_party/fmt/**/*.h"]),
    includes = ["third_party"],
    linkopts = select({
        "@platforms//os:macos": [
            "-L/opt/homebrew/opt/fmt/lib",
            "-lfmt",
        ],
        "@platforms//os:linux": [
            "-L/usr/local/lib",
            "-L/usr/lib/x86_64-linux-gnu",
            "-lfmt",
        ],
        "//conditions:default": [
            "-L/usr/local/lib",
            "-lfmt",
        ],
    }),
    visibility = ["//visibility:public"],
)
```

#### brpc Library Dependencies
```starlark
cc_library(
    name = "brpc",
    # ... other configurations ...
    deps = [
        ":brpc_internal_cc_proto",
        ":bthread",
        ":butil",
        ":bvar",
        ":json2pb",
        ":mcpack2pb",
        ":couchbase_headers",
        ":fmt_headers",
        "@com_github_google_leveldb//:leveldb",
    ] + select({
        "//bazel/config:brpc_with_thrift": [
            "@org_apache_thrift//:thrift",
        ],
        "//conditions:default": [],
    }),
)
```

#### Exclude List (should NOT contain couchbase files)
```starlark
exclude = [
    "src/brpc/thrift_service.cpp",
    "src/brpc/thrift_message.cpp",
    "src/brpc/policy/thrift_protocol.cpp",
    "src/brpc/event_dispatcher_epoll.cpp",
    "src/brpc/event_dispatcher_kqueue.cpp",
    # Note: couchbase.cpp and couchbase_authenticator.cpp should NOT be excluded
]
```

## Build Commands

### 1. Build the Main Library
```bash
# Build the brpc library
bazel build //:brpc

# Verify the build was successful
ls -la bazel-bin/libbrpc.a
```

### 2. Build Examples (Optional)
```bash
# Build echo example
bazel build //example:echo_c++_server //example:echo_c++_client

# Build all examples
bazel build //example/...
```

### 3. Verify Couchbase Integration
```bash
# Check if Couchbase symbols are present in the library
nm bazel-bin/libbrpc.a | grep -i couchbase | head -10
```

Expected output should include symbols like:
- `CouchbaseWrapper::InitCouchbase`
- `CouchbaseWrapper::CouchbaseGet`
- `CouchbaseWrapper::CouchbaseAdd`
- `CouchbaseWrapper::CouchbaseRemove`

## Cross-Platform Configuration

The BUILD.bazel file now uses Bazel's `select()` function to automatically choose the correct library paths based on the target platform. This means:

### ✅ **Single Configuration Works for Both Platforms**
- **No manual path changes needed** when switching between macOS and Linux
- **Automatic platform detection** using `@platforms//os:macos` and `@platforms//os:linux`
- **Fallback configuration** for other platforms using `"//conditions:default"`

### 🔧 **How It Works**
The configuration automatically selects:

**macOS:**
- Couchbase: `/opt/homebrew/opt/couchbase-cxx-client/lib`
- fmt: `/opt/homebrew/opt/fmt/lib`

**Linux:**
- Couchbase: `/usr/local/lib` and `/usr/lib/x86_64-linux-gnu`
- fmt: `/usr/local/lib` and `/usr/lib/x86_64-linux-gnu`

## Platform-Specific Notes

### macOS Specific
- Use Homebrew for package management
- Bazel requires the specific version 7.2.1 for this project
- sed command syntax requires empty string parameter for in-place editing
- Library paths use `/opt/homebrew/opt/` prefix (automatically selected)

### Linux Specific
- Package names may vary between distributions
- Library paths typically use `/usr/lib` or `/usr/local/lib` (automatically selected)
- May need to run `sudo ldconfig` after installing libraries
- Some distributions may require building dependencies from source
- Multiple library paths are checked automatically (`/usr/local/lib` and `/usr/lib/x86_64-linux-gnu`)

## Troubleshooting

### Common Issues

#### 1. Bazel Version Mismatch
```bash
# Check current Bazel version
bazel version

# If wrong version, follow platform-specific installation steps above
```

#### 2. Missing Headers
```bash
# Verify symlinks are correct
ls -la third_party/couchbase/cluster.hxx
ls -la third_party/fmt/format.h

# If missing, recreate symlinks using commands from step 2 above
```

#### 3. Linker Errors
```bash
# Check if libraries are installed
ldconfig -p | grep couchbase
ldconfig -p | grep fmt

# Update library paths in BUILD.bazel if needed
```

#### 4. Permission Issues (Linux)
```bash
# Ensure proper permissions for installed libraries
sudo chmod 755 /usr/local/lib/libcouchbase_cxx_client.so*
sudo chmod 755 /usr/local/lib/libfmt.so*
```

## Build Verification

After successful build, you should see:
1. `bazel-bin/libbrpc.a` file created
2. No compilation errors related to missing Couchbase or fmt headers
3. Couchbase symbols present in the library (verified with `nm` command)
4. All example binaries building successfully

## Additional Resources

- [brpc Official Documentation](https://github.com/apache/brpc)
- [Couchbase C++ Client Documentation](https://docs.couchbase.com/cxx-sdk/current/hello-world/start-using-sdk.html)
- [Bazel Build System Documentation](https://bazel.build/docs)
- [fmt Library Documentation](https://fmt.dev/)

## Support

If you encounter issues:
1. Check the troubleshooting section above
2. Verify all dependencies are properly installed
3. Ensure symlinks are correctly created
4. Check platform-specific notes for your operating system
