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
}:

let
  inherit (python312Packages)
    mypy
    pybind11
    pybind11-stubgen
    ;

  # depthai-bootloader-fwp
  datasrc = [ (fetchurl {
        url = "https://artifacts.luxonis.com/artifactory/luxonis-myriad-snapshot-local/depthai-bootloader/0.0.19+042ea79ae0014054dcb3fc3377229aa6c95ebf3f/depthai-bootloader-fwp-0.0.19+042ea79ae0014054dcb3fc3377229aa6c95ebf3f.tar.xz";
        hash = "sha256-A8NBwCC+3ee1Mms4s61jAMa+Ji5zpuz7yvWW3AFFIf0="; })

        (fetchurl {
        url = "https://artifacts.luxonis.com/artifactory/luxonis-depthai-data-local/network/mobilenet-ssd_openvino_2021.4_6shave.blob";
        hash = "sha256-WunLY2v6QN8Cwso+ZLxopmkKvYoUeQPUWArqa2/rnBw="; })

 (fetchurl {
         url = "http://artifacts.luxonis.com/artifactory/luxonis-depthai-data-local/network/yolo-v3-tiny-tf_openvino_2021.4_6shave.blob";
         hash = "sha256-8nKaQuJ36ZS6aPDpFLZv5SzmZRdagKVZa41Q0YsiA0M="; })
 
 (fetchurl {
         url = "https://artifacts.luxonis.com/artifactory/luxonis-depthai-data-local/network/yolo-v4-tiny-tf_openvino_2021.4_6shave.blob";
         hash = "sha256-AinAaP8iBjGv/TI7hO7Ohlv+KNX+iVCrYCglqERLhvQ="; })
 
 (fetchurl {
         url = "https://artifacts.luxonis.com/artifactory/luxonis-depthai-data-local/network/mobilenet-ssd_openvino_2021.4_5shave.blob";
         hash = "sha256-eC2AkCxc59oB+PyDiUto2jMhbtyT2Ur7Ft11dqJeUOI="; })

 (fetchurl {
         url = "https://artifacts.luxonis.com/artifactory/luxonis-depthai-data-local/network/mobilenet-ssd_openvino_2021.4_8shave.blob";
         hash = "sha256-jJoBidlVgLJELIhTmvMZikM+/UG5sIN86o0JpNFqLUo="; })

 (fetchurl {
         url = "https://artifacts.luxonis.com/artifactory/luxonis-depthai-data-local/network/construction_vest.mp4";
         hash = "sha256-LzXqNaQemO4X3JE2xJXtD/Oqe6Z3TV7twrmTU1DGCE8="; })
 
 (fetchurl {
         url = "https://artifacts.luxonis.com/artifactory/luxonis-depthai-data-local/misc/depthai_calib.json";
         hash = "sha256-8n3AWlfS2WQYnkWVmbFjNVbcZH5no7fj63/hsAdA8Vc="; })
 
 (fetchurl {
         url = "https://artifacts.luxonis.com/artifactory/luxonis-depthai-data-local/misc/depthai_v5.calib";
         hash = "sha256-wliQIiLXuexV7uVrGzklX5o7tVwC64xSKPWiUccHQO4="; })
 
 (fetchurl {
         url = "https://artifacts.luxonis.com/artifactory/luxonis-depthai-data-local/misc/BW1098OBC.json";
         hash = "sha256-/tZnr9VOl7SRjxEYeIrhSs1kYaxjZIUOMmhs4RH6RSg="; })
 
 (fetchurl {
         url = "https://artifacts.luxonis.com/artifactory/luxonis-depthai-data-local/network/person-detection-retail-0013_openvino_2021.4_7shave.blob";
         hash = "sha256-Sl1+98J9265Ro7/iCwkwBvRLO2MpyNX2SC+fNIshrTc="; })
 
 (fetchurl {
         url = "https://artifacts.luxonis.com/artifactory/luxonis-depthai-data-local/network/concat_openvino_2021.4_6shave.blob";
         hash = "sha256-asMCPqjaybdQHq0PmywqRJXSeRpYtwSd4GUkZFXPh74="; })
 
 (fetchurl {
         url = "https://artifacts.luxonis.com/artifactory/luxonis-depthai-data-local/network/normalize_openvino_2021.4_4shave.blob";
         hash = "sha256-m13Es3XtkhjCkQKEVW+BUsv8wBMOe3pC2amZHq6L4jo="; })

(fetchurl {
        url = "https://download.01.org/opencv/2021/openvinotoolkit/2021.1/open_model_zoo/models_bin/1/person-detection-0202/FP32/person-detection-0202.xml";
        hash = "sha256-XwsXQ78KzUJ4tkyAY8esq5adnvDBQfMpSYqgpqmqOf8="; })

 (fetchurl {
         url = "https://download.01.org/opencv/2021/openvinotoolkit/2021.1/open_model_zoo/models_bin/1/person-detection-0202/FP32/person-detection-0202.bin";
        hash = "sha256-UdleZDcz0qEa2DC5VPjDzJ4VwI/6t5a+DJbDfpnifoM="; })

(fetchurl {
        url = "https://github.com/luxonis/depthai-model-zoo/raw/main/models/yolov4_tiny_coco_416x416/yolov4_tiny_coco_416x416.xml";
        hash = "sha256-yIhLN3VoQGuqVTEgUyvcbTtVQ5FCnjSYMHxxnvOzRJ4="; })

 (fetchurl {
         url = "https://robothub.fra1.cdn.digitaloceanspaces.com/models/yolov4_tiny_coco_416x416/yolov4_tiny_coco_416x416.bin";
         hash = "sha256-mfo6SZ+lDJsG9KPV8eQxMSnKB4q8d4UhZqv0v1rGARU="; })
 
 (fetchurl {
         url = "https://artifacts.luxonis.com/artifactory/luxonis-depthai-data-local/network/nnarchive/yolo-v6-openvino_2022.1_6shave-rvc2.tar.xz";
         hash = "sha256-Xm8oBZfVj/ZpqCe0HBIiLmP6sQ5Y3djZtALBn9IdcTA="; })
];

  testsrc = [ (fetchurl {
        url = "https://artifacts.luxonis.com/artifactory/luxonis-depthai-data-local/network/mobilenet-ssd_openvino_2021.2_8shave.blob";
        hash = "sha256-4MYBVu6XsBrBFa2DjRPI2QVZBk/sBMbUI7sD/cQFJOs="; })

        (fetchurl {
        url = "https://artifacts.luxonis.com/artifactory/luxonis-depthai-data-local/network/text-image-super-resolution-0001_2020.3_4shave.blob";
        hash = "sha256-aB+4Uyxbnjn0C0My8+1c7eRUMF05k7cRvsS7MfRImTo="; })

        (fetchurl {
        url = "https://artifacts.luxonis.com/artifactory/luxonis-depthai-data-local/network/text-image-super-resolution-0001_2020.4_4shave.blob";
        hash = "sha256-hAgAyMwEOkM1LzpUOOw1xHfeGeba8y2Z1MvPRUKUmjc="; })

        (fetchurl {
        url = "https://artifacts.luxonis.com/artifactory/luxonis-depthai-data-local/network/text-image-super-resolution-0001_2021.1_4shave.blob";
        hash = "sha256-lVCjt2qKfph9HSiBOZqoTtZx7H1iJawgos16z5Rx8DQ="; })

        (fetchurl {
        url = "https://artifacts.luxonis.com/artifactory/luxonis-depthai-data-local/network/text-image-super-resolution-0001_2021.2_4shave.blob";
        hash = "sha256-sPiMds+kpBWGFPZUttobRgATf9id8H6fc8uIkxRqS14="; })

        (fetchurl {
        url = "https://artifacts.luxonis.com/artifactory/luxonis-depthai-data-local/network/text-image-super-resolution-0001_2021.3_4shave.blob";
        hash = "sha256-blY/4fDaTR+BOs/7FgUMSrU7qpjYgYUUY5A24VayhX8="; })

        (fetchurl {
        url = "https://artifacts.luxonis.com/artifactory/luxonis-depthai-data-local/network/text-image-super-resolution-0001_2021.4.2_4shave.blob";
        hash = "sha256-XIPLPOfVopNXqXXl3zzRFjdBoTNpXHkEzUQI4z8H8bw="; })

        (fetchurl {
        url = "https://artifacts.luxonis.com/artifactory/luxonis-depthai-data-local/network/text-image-super-resolution-0001_2022.1.0_4shave.blob";
        hash = "sha256-Ok7EhNKJCDWtsjnAauHyKxFBwCzHC9JmG3+eN3A6I+4="; })

        (fetchurl {
        url = "https://artifacts.luxonis.com/artifactory/luxonis-depthai-data-local/network/yolo-v4-tiny-tf_openvino_2021.4_4shave.blob";
        hash = "sha256-aOn8BJcfYCA4RXUF99kPPbgeC/b3O/oOH+1Uhuxv/MM="; })

        (fetchurl {
        url = "https://artifacts.luxonis.com/artifactory/luxonis-depthai-data-local/network/person-reidentification-retail-0277_openvino_2022.1_8shave.superblob";
        hash = "sha256-mXvM/HSe1PaZ4M/MPdfDm09A12MgG9qFwcJxe+XWBfs="; })

        (fetchurl {
        url = "https://artifacts.luxonis.com/artifactory/luxonis-depthai-data-local/network/nnarchive/yolo_blob_nnarchive.tar.xz";
        hash = "sha256-tqqrvv/PSkHCss7hhpdndRzRq0qQWn1ZEpb+A6d4gZI="; })

        (fetchurl {
        url = "https://artifacts.luxonis.com/artifactory/luxonis-depthai-data-local/network/nnarchive/yolo_superblob_nnarchive.tar.xz";
        hash = "sha256-lH/Ulvbn5UOZ9T59G9HocTPBefw2s10Ih/zl+yoPTXg="; })

        (fetchurl {
        url = "https://artifacts.luxonis.com/artifactory/luxonis-depthai-data-local/network/nnarchive/yolo_onnx_nnarchive.tar.xz";
        hash = "sha256-oBrCwV07sicg6rBCAFlQ9gptRk1z+j0KeSN6cAtXzGU="; })

        (fetchurl {
        url = "https://artifacts.luxonis.com/artifactory/luxonis-depthai-data-local/images/lenna.png";
        hash = "sha256-fkl1AaKLz5o1PMrfbrkha/CYrDKIj7VC+5v+cdSGdh8="; })
];
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
    ./001-build.patch
  ];

  nativeBuildInputs = [
    cmake
    clang-tools
    git
    pkg-config
    catch2_3
  ];

  buildInputs = [
    gcc-unwrapped.lib # provides libstdc++.so.6
    argparse
    boost186
    libusb1
    libpng
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
  ];

  propagatedBuildInputs = [ pybind11 pybind11-stubgen mypy ];

  cmakeFlags = [
    "-DDEPTHAI_BOOTSTRAP_VCPKG=OFF"
    "-DBUILD_SHARED_LIBS=ON"
    "-DDEPTHAI_BUILD_EXAMPLES=ON"
    "-DDEPTHAI_TEST_EXAMPLES=ON"
    "-DDEPTHAI_PCL_SUPPORT=ON"
    #"-DDEPTHAI_BUILD_TESTS=ON"
    #"-DDEPTHAI_BUILD_PYTHON=ON"
    #"-DDEPTHAI_RESOURCES_OUTPUT_DIR=${datasrc}"
  ];

#  postInstall = ''
#    mkdir -p $out/share/${pname}
#    
#    # Find all executables in the build directory and copy them to share
#    find $buildDir -type f -executable -not -path "*/\.*" | while read exec_file; do
#      cp "$exec_file" $out/share/${pname}/
#    done
#    
#    # Create a file listing all available executables
#    ls -la $out/share/${pname} > $out/share/${pname}/executable_list.txt
#  '';

  # Add rpath to all executables to find the libraries
  postFixup = ''
    mkdir -p $out/share/
    mkdir -p $out/lib/
   
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

  meta = with lib; {
    description = "Core C++ library for Luxonis OAK devices";
    homepage = "https://github.com/luxonis/depthai-core";
    license = licenses.mit;
    platforms = platforms.linux;
    maintainers = with maintainers; [ /* your maintainer name here */ ];
  };
}
