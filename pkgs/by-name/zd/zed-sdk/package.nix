{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  pkg-config,
  cudaPackages,
  libusb1,
  glew,
  freeglut,
  libGL,
  libGLU,
  xorg,
  eigen,
  boost,
  opencv4,
  python3,
  glog,
  glm,
  udev,
  vulkan-headers,
  vulkan-loader,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "zed-sdk";
  version = "4.2.1";

  src = fetchFromGitHub {
    owner = "stereolabs";
    repo = "zed-sdk";
    rev = "${finalAttrs.version}";
    sha256 = "sha256-ymOpBTv8oLSdOYN+RmuGDjwdbgJOxDoUvsX+m1QSvmk=";
  };

  nativeBuildInputs = [
    cmake
    pkg-config
    cudaPackages.cuda_nvcc
  ];

  buildInputs = [
    cudaPackages.cuda_cudart
    cudaPackages.cuda_cccl
    cudaPackages.libcublas
    cudaPackages.libcusolver
    cudaPackages.libcusparse
    libusb1
    glew
    freeglut
    libGL
    libGLU
    xorg.libX11
    xorg.libXi
    xorg.libXmu
    eigen
    boost
    opencv4
    python3
    glog
    glm
    udev
    vulkan-headers
    vulkan-loader
  ];

  cmakeFlags = [
    (lib.cmakeFeature "CMAKE_BUILD_TYPE" "Release")
    (lib.cmakeFeature "CMAKE_CUDA_COMPILER" "${cudaPackages.cuda_nvcc}/bin/nvcc")
    (lib.cmakeFeature "CMAKE_CUDA_HOST_COMPILER" "${stdenv.cc}/bin/cc")
    (lib.cmakeBool "ZED_EXAMPLES" true)
    (lib.cmakeBool "ZED_PYTHON_BINDINGS" true)
    (lib.cmakeBool "ZED_OPENCV_SUPPORT" true)
  ];

  # Fix for CUDA paths
  preConfigure = ''
    export CUDA_PATH=${cudaPackages.cuda_cudart}
    export CUDA_TOOLKIT_ROOT_DIR=${cudaPackages.cuda_cudart}
  '';

  # Make sure USB rules are installed
  postInstall = ''
    # Install udev rules
    mkdir -p $out/lib/udev/rules.d
    if [ -f $src/resources/99-zed.rules ]; then
      cp $src/resources/99-zed.rules $out/lib/udev/rules.d/
    fi

    # Copy all examples to a share directory
    mkdir -p $out/share/${finalAttrs.pname}/examples
    if [ -d $buildDir/examples ]; then
      find $buildDir/examples -type f -executable -not -path "*/\.*" | while read exec_file; do
        cp "$exec_file" $out/share/${finalAttrs.pname}/examples/
      done
    fi
  '';

  # Fix library paths for the executables
  postFixup = ''
    # Find all shared libraries and make sure they're included in the runtime path
    mkdir -p $out/lib/${finalAttrs.pname}

    # Copy any shared libraries from the build directory
    find $buildDir -name "*.so*" -type f -not -name "*.a" -not -path "*/\.*" | while read lib_file; do
      lib_basename=$(basename "$lib_file")
      if [ ! -e "$out/lib/${finalAttrs.pname}/$lib_basename" ]; then
        cp -P "$lib_file" $out/lib/${finalAttrs.pname}/
      fi
    done

    # Create symlinks in the main lib directory if they don't exist
    for lib_file in $out/lib/${finalAttrs.pname}/*.so*; do
      if [ -f "$lib_file" ]; then
        lib_basename=$(basename "$lib_file")
        if [ ! -e "$out/lib/$lib_basename" ]; then
          ln -sf "$lib_file" $out/lib/
        fi
      fi
    done

    # Fix rpath for all executables in bin and share/examples
    CUDA_LIB_PATH="${cudaPackages.cuda_cudart}/lib:${cudaPackages.libcublas}/lib:${cudaPackages.libcusolver}/lib:${cudaPackages.libcusparse}/lib"

    for bin_dir in "$out/bin" "$out/share/${finalAttrs.pname}/examples"; do
      if [ -d "$bin_dir" ]; then
        for f in $bin_dir/*; do
          if [ -f "$f" ] && [ -x "$f" ]; then
            echo "Patching $f"
            patchelf --set-rpath "${lib.makeLibraryPath finalAttrs.buildInputs}:$CUDA_LIB_PATH:$out/lib:$out/lib/${finalAttrs.pname}" "$f" || true
          fi
        done
      fi
    done

    # Also patch the Python bindings if they exist
    if [ -d "$out/lib/python3" ]; then
      find "$out/lib/python3" -name "*.so" | while read pylib; do
        echo "Patching Python binding $pylib"
        patchelf --set-rpath "${lib.makeLibraryPath finalAttrs.buildInputs}:$CUDA_LIB_PATH:$out/lib:$out/lib/${finalAttrs.pname}" "$pylib" || true
      done
    fi

    # Create summary files
    ls -la $out/bin > $out/share/${finalAttrs.pname}/binary_list.txt || true
    ls -la $out/lib/${finalAttrs.pname} > $out/share/${finalAttrs.pname}/library_list.txt || true
    if [ -d "$out/share/${finalAttrs.pname}/examples" ]; then
      ls -la $out/share/${finalAttrs.pname}/examples > $out/share/${finalAttrs.pname}/examples_list.txt || true
    fi
  '';

  meta = {
    description = "Stereolabs ZED SDK for stereo cameras";
    homepage = "https://github.com/stereolabs/zed-sdk";
    license = lib.licenses.unfree;
    platforms = lib.platforms.linux;
    maintainers = with lib.maintainers; [ phodina ];
  };
})
