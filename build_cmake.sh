#!/bin/bash
# Build script for CCTBX using CMake

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Default values
BUILD_TYPE="Release"
BUILD_DIR="cmake-build"
INSTALL_PREFIX="${HOME}/.local"
JOBS=$(nproc 2>/dev/null || sysctl -n hw.ncpu 2>/dev/null || echo 4)
USE_CONDA=OFF
ENABLE_OPENMP=OFF
ENABLE_CUDA=OFF

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -d|--debug)
            BUILD_TYPE="Debug"
            shift
            ;;
        -r|--release)
            BUILD_TYPE="Release"
            shift
            ;;
        -j|--jobs)
            JOBS="$2"
            shift 2
            ;;
        --build-dir)
            BUILD_DIR="$2"
            shift 2
            ;;
        --prefix)
            INSTALL_PREFIX="$2"
            shift 2
            ;;
        --conda)
            USE_CONDA=ON
            shift
            ;;
        --openmp)
            ENABLE_OPENMP=ON
            shift
            ;;
        --cuda)
            ENABLE_CUDA=ON
            shift
            ;;
        -h|--help)
            echo "Usage: $0 [options]"
            echo ""
            echo "Options:"
            echo "  -d, --debug         Build in Debug mode (default: Release)"
            echo "  -r, --release       Build in Release mode"
            echo "  -j, --jobs N        Number of parallel jobs (default: auto-detect)"
            echo "  --build-dir DIR     Build directory (default: cmake-build)"
            echo "  --prefix DIR        Installation prefix (default: ~/.local)"
            echo "  --conda             Use Conda environment"
            echo "  --openmp            Enable OpenMP support"
            echo "  --cuda              Enable CUDA support"
            echo "  -h, --help          Show this help message"
            exit 0
            ;;
        *)
            echo -e "${RED}Unknown option: $1${NC}"
            echo "Use -h or --help for usage information"
            exit 1
            ;;
    esac
done

echo -e "${GREEN}=== CCTBX CMake Build ===${NC}"
echo "Build type: $BUILD_TYPE"
echo "Build directory: $BUILD_DIR"
echo "Install prefix: $INSTALL_PREFIX"
echo "Jobs: $JOBS"
echo "Use Conda: $USE_CONDA"
echo "OpenMP: $ENABLE_OPENMP"
echo "CUDA: $ENABLE_CUDA"
echo ""

# Create build directory
mkdir -p "$BUILD_DIR"
cd "$BUILD_DIR"

# Configure with CMake
echo -e "${YELLOW}Configuring with CMake...${NC}"
cmake .. \
    -DCMAKE_BUILD_TYPE="$BUILD_TYPE" \
    -DCMAKE_INSTALL_PREFIX="$INSTALL_PREFIX" \
    -DUSE_CONDA="$USE_CONDA" \
    -DENABLE_OPENMP="$ENABLE_OPENMP" \
    -DENABLE_CUDA="$ENABLE_CUDA" \
    -DCMAKE_EXPORT_COMPILE_COMMANDS=ON

# Build
echo -e "${YELLOW}Building...${NC}"
cmake --build . -j "$JOBS"

# Test (if tests are available)
if [ -f "CTestTestfile.cmake" ]; then
    echo -e "${YELLOW}Running tests...${NC}"
    ctest --output-on-failure
fi

echo -e "${GREEN}Build completed successfully!${NC}"
echo ""
echo "To install, run:"
echo "  cd $BUILD_DIR && cmake --install ."
echo ""
echo "To use the build without installing:"
echo "  export PYTHONPATH=$(pwd)/lib:\$PYTHONPATH"
echo "  export LD_LIBRARY_PATH=$(pwd)/lib:\$LD_LIBRARY_PATH"

