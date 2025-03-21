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
, apriltags
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

  opencv4WithGtk = opencv4.override {
    enableGtk2 = true;  # For GTK2 support
    enableGtk3 = true;  # For GTK3 support
  };
  inherit (python312Packages)
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
    sha256 = "sha256-Ayd4kwcOJewIGmfuSu8Hs91YPfcxOSmIK5RfLMVbTk8=";
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
    apriltags
    xlink
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

  propagatedBuildInputs = [ pybind11 pybind11-stubgen mypy ];

  cmakeFlags = [
    #(cmakeBool "DEPTHAI_BOOTSTRAP_VCPKG" false)
    #(cmakeBool "BUILD_SHARED_LIBS" true)
    #(cmakeBool "DEPTHAI_BUILD_EXAMPLES" true)
    #(cmakeBool "DEPTHAI_TEST_EXAMPLES" true)
    #(cmakeBool "DEPTHAI_PCL_SUPPORT" true)
    #(cmakeBool "CMAKE_VERBOSE_MAKEFILE" true)
    #(cmakeBool "DEPTHAI_BUILD_TESTS" true)
    #(cmakeBool "DEPTHAI_BUILD_PYTHON" true)
  ];

  postPatch = ''
      #substituteInPlace CMakeLists.txt --replace-fail "@NIX_PATH@" "${depthai-data}/share/resources/"
      substituteInPlace CMakeLists.txt --replace-fail "@NIX_PATH@" "/build/source/build/resources/"

    mkdir -p /build/source/build/resources
    cp ${depthai-data}/share/resources/* /build/source/build/resources
    find /build/source/build/resources

    # Remove 3rdparty directory
    if [ -d 3rdparty ]; then
      rm -rf 3rdparty
    fi

  '';

  # Add rpath to all executables to find the libraries
  postFixup = ''
    mkdir -p $out/share/
    mkdir -p $out/lib/
    mkdir -p $out/lib/${python3.sitePackages}

    export PYTHONPATH="$out/${python3.sitePackages}:$PYTHONPATH"
    
    # Copy any additional Python files if they're not already in the right place
    find $buildDir/depthai/python
    if [ -d $buildDir/depthai/python ]; then
       cp -r $buildDir/depthai/python $out/lib/${python3.sitePackages}/
    fi
   
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

    # Remove garbage
    rm -r $out/lib/cmake
  '';

  meta = with lib; {
    description = "Core C++ library for Luxonis OAK devices";
    homepage = "https://github.com/luxonis/depthai-core";
    license = licenses.mit;
    platforms = platforms.linux;
    maintainers = with maintainers; [ /* your maintainer name here */ ];
  };
}
