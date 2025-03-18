{ lib
, stdenv
, fetchurl
, fetchFromGitHub
, cmake
, gcc
, gcc-unwrapped
, clang-tools
, pkg-config
, libusb1
, opencv4
, boost186
, libpng
, libarchive
, httplib
, openssl
, protobuf
, xtensor
, cproto
, eigen
, yaml-cpp
, jsoncpp
, spdlog
, argparse
, magic-enum
, nlohmann_json
, libnop
, websocketpp
, mp4v2
, neargye-semver
, backward-cpp
, pcl
, python3
, python312Packages
, catch2_3
, xorg
, git
, bzip2
, lz4
, xz
, apriltag
, xlink
, fp16
, curl
, cpr
, xtl
, fmt
, zlib
, depthai-data
, ws-protocol
}:

let
  catch2_3WithSharedLibs = catch2_3.overrideAttrs (oldAttrs: {
    cmakeFlags = (oldAttrs.cmakeFlags or []) ++ [
      "-DBUILD_SHARED_LIBS=ON"
    ];
  });

  # Latest commits are not compatible, use older version
  xlinkCompat = xlink.overrideAttrs (old: {
    src = fetchFromGitHub {
      owner = "Luxonis";
      repo = "xlink";
      rev = "7f5633ab542df632acaf4ccaf5e98d30f984e6e4";
      hash = "sha256-jZQhH4xZgwM/439GkOr28Xrh1D18vh3jMPiRJR8WdD0=";
    };

    patches = [ ./001-Xlink-Remove-Hunter.patch ];

    postInstall = ''
    mkdir -p $out/include
    mkdir -p $share/examples
    mkdir -p $share/tests

    cp -r $src/include/* $out/include/

    examples=(
      "boot_firmware"
      "list_devices"
      "boot_bootloader"
      "search_devices"
      "Makefile"
      "device_connect_reset"
    )

    find $buildDir
    for file in "''${examples[@]}"; do
      cp examples/$file $share/examples/$file
    done
  '';
  });

  opencv4WithGtk = opencv4.override {
    enableGtk2 = true;  # For GTK2 support
    enableGtk3 = true;  # For GTK3 support
  };
  inherit (python312Packages)
    numpy
    mypy
    pybind11
    pybind11-stubgen
    ;
in
stdenv.mkDerivation rec {
  pname = "depthai-core";
  version = "3.0.0-alpha.14";

  src = fetchFromGitHub {
    owner = "luxonis";
    repo = "depthai-core";
    rev = "v${version}";
    hash = "sha256-Ayd4kwcOJewIGmfuSu8Hs91YPfcxOSmIK5RfLMVbTk8=";
    fetchSubmodules = true;
  };

  patches = [
    ./0001-CMakeLists.txt-Fix-dependencies.patch
    ./0002-CMakeLists.txt-Add-embedded-dependencies.patch
    ./0003-CMakeLists.txt-Link-crypto-library-due-to-OpenSSL-re.patch
    ./0004-CMakeLists-backward-dependency.patch
    ./0005-CMakeLists-Do-not-install-3rdparty-source-code.patch
    ./0006-cmake-Disable-downloaders-for-container-build.patch
    ./0007-cmake-Sort-out-dependencies-for-depthai.patch
    ./0008-examples-Don-t-download-dependencies.patch
    ./0009-Color.hpp-Explicit-specification-for-float-type.patch
    ./0010-StreamMessageParser.cpp-Add-case-for-DatatypeEnum-Im.patch
    ./0011-BenchmarkOut.cpp-Explicit-cast-to-double.patch
    ./0012-cmake-Handle-catch2-dependencies-for-tests.patch
    ./0013-cmake-Don-t-download-the-test-dependencies.patch
    ./0014-cmake-Install-examples-after-build-WIP.patch
    ./016-resources.patch
  ];

  nativeBuildInputs = [
    cmake
    clang-tools
    git
    pkg-config
  ];

  buildInputs = [
    gcc-unwrapped.lib # provides libstdc++.so.6
    argparse
    boost186
    libusb1
    libpng
    opencv4WithGtk
    opencv4
    xorg.libX11
    httplib
    openssl
    protobuf
    cproto
    xtensor
    xtl
    magic-enum
    nlohmann_json
    libnop
    websocketpp
    mp4v2
    neargye-semver
    backward-cpp
    spdlog
    yaml-cpp
    apriltag
    xlinkCompat
    cpr
    fp16
    curl
    mp4v2
    pcl
    eigen
    jsoncpp
    fmt
    libarchive
    bzip2
    lz4
    xz
    zlib
    depthai-data
    ws-protocol
    catch2_3WithSharedLibs
  ];

  # Limit due to examples when linking in parallel requires to much memory
  NIX_BUILD_CORES = 12;

  propagatedBuildInputs = [ numpy pybind11 pybind11-stubgen mypy ];

  cmakeFlags = [
    (lib.cmakeBool "DEPTHAI_BOOTSTRAP_VCPKG" false)
    (lib.cmakeBool "BUILD_SHARED_LIBS" true)
    (lib.cmakeBool "DEPTHAI_BUILD_EXAMPLES" true)
    (lib.cmakeBool "DEPTHAI_TEST_EXAMPLES" true)
    (lib.cmakeBool "DEPTHAI_PCL_SUPPORT" true)
    (lib.cmakeBool "DEPTHAI_BUILD_TESTS" true)
    (lib.cmakeBool "DEPTHAI_BUILD_PYTHON" true)
    (lib.cmakeBool "DEPTHAI_PYTHON_ENABLE_TESTS" true)
# NOTE: Dependency broken
#    (lib.cmakeBool "DEPTHAI_BASALT_SUPPORT" true)
# NOTE: Broken atm
    #(lib.cmakeBool "DEPTHAI_RTABMAP_SUPPORT" true)
  ];

  # Add rpath to all executables to find the libraries
  postFixup = ''
    mkdir -p $out/share/
    mkdir -p $out/lib/
    mkdir -p $out/${python3.sitePackages}
    mkdir -p $out/share/python-examples

    #export PYTHONPATH="$out/${python3.sitePackages}:$PYTHONPATH"
    
    # Copy any additional Python files if they're not already in the right place
    if [ -d $buildDir/build/source/build/bindings/python ]; then
       mkdir -p $out/${python3.sitePackages}/depthai_cli

       cp -r $buildDir/build/source/build/bindings/python/depthai $out/${python3.sitePackages}/
       cp $src/bindings/python/utilities/stress_test.py $out/${python3.sitePackages}/depthai_cli
       cp $src/bindings/python/utilities/cam_test.py $out/${python3.sitePackages}/depthai_cli
       cp $src/bindings/python/depthai_cli/__init__.py $out/${python3.sitePackages}/depthai_cli
       cp $src/bindings/python/depthai_cli/depthai_cli.py $out/${python3.sitePackages}/depthai_cli
    fi

    # Copy Python examples
    cp -r $src/examples/python/* $out/share/python-examples
    #find $src/examples/python -type d -mindepth 1 | while read -r dir; do
    #  dirName=$(basename "$dir")
    #  cp -r "$dir" $out/share/python-examples
    #done

    # Find all shared libraries in the build directory and copy them to lib directory
    find $buildDir -name "*.so*" -type f -not -path "*/\.*" | while read lib_file; do
      cp -P "$lib_file" $out/lib/
    done
    
    # Find all shared libraries in the build directory and copy them to lib directory
    # Exclude static libraries (.a files) and only copy shared objects (.so files)
    find $buildDir -name "*.so*" -type f -not -name "*.a" -not -path "*/\.*" | while read lib_file; do
      lib_basename=$(basename "$lib_file")
      if [ ! -e "$out/lib/$lib_basename" ]; then
        cp -P "$lib_file" $out/lib/
      else
        echo "Skipping $lib_basename as it already exists in $out/lib/"
      fi
    done
 
    # Find all executables in the build directory and copy them to share
    find $buildDir -type f -executable -not -path "*/\.*" | while read exec_file; do
      cp "$exec_file" $out/share/
    done
    
    # Patch the executables in the share directory
    for f in $out/share/*; do
      if [ -f "$f" ] && [ -x "$f" ]; then
        echo "Patching $f"
        patchelf --set-rpath "${lib.makeLibraryPath buildInputs}:$out/lib" "$f" || true
      fi
    done
    
    # Also patch the binaries in the bin directory
    for f in $out/bin/*; do
      if [ -f "$f" ] && [ -x "$f" ]; then
        echo "Patching $f"
        patchelf --set-rpath "${lib.makeLibraryPath buildInputs}:$out/lib" "$f" || true
      fi
    done
  '';

  postPatch = ''
    substituteInPlace CMakeLists.txt --replace-fail "@NIX_PATH@" "/build/source/build/resources/"

    mkdir -p /build/source/build/resources
    # NOTE: Replace with symlink?
    cp ${depthai-data}/share/resources/* /build/source/build/resources
    find /build/source/build/resources

    # Remove 3rdparty directory
    rm -rf 3rdparty

  '';

  meta = with lib; {
    description = "Core C++ library for Luxonis OAK devices";
    homepage = "https://github.com/luxonis/depthai-core";
    license = licenses.mit;
    platforms = platforms.linux;
    maintainers = with maintainers; [ /* your maintainer name here */ ];
  };
}
