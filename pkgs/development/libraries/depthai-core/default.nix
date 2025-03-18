{ lib
, stdenv
, fetchurl
, fetchFromGitHub
, cmake
, clang-tools
, pkg-config
, libusb1
, opencv4
, boost186
, libpng
, libarchive
, httplib
, openssl_3
, protobuf
, xtensor
, cproto
, yaml-cpp
, spdlog
, argparse
, magic-enum
, nlohmann_json
, libnop
, websocketpp
, mp4v2
, neargye-semver
, backward-cpp
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
}:

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

  patches = [
    ./001-build.patch
  ];

  nativeBuildInputs = [
    cmake
    clang-tools
    git
    pkg-config
    libarchive
    bzip2
    lz4
    xz
  ];

  buildInputs = [
    argparse
    boost186
    libusb1
    libpng
    opencv4
    xorg.libX11
    httplib
    openssl_3
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
  ];

  propagatedBuildInputs = [ mp4v2 curl ];

  cmakeFlags = [
    "-DDEPTHAI_BOOTSTRAP_VCPKG=OFF"
    "-DBUILD_SHARED_LIBS=ON"
    "-DDEPTHAI_BUILD_EXAMPLES=ON"
  ];

  meta = with lib; {
    description = "Core C++ library for Luxonis OAK devices";
    homepage = "https://github.com/luxonis/depthai-core";
    license = licenses.mit;
    platforms = platforms.linux;
    maintainers = with maintainers; [ /* your maintainer name here */ ];
  };
}
