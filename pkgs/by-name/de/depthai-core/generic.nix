{
  lib,
  stdenv,
  cmake,
  fetchFromGitHub,
  fetchzip,
  fetchpatch,
  opencv4,
  python3Packages,
  clang-tools,
  pkg-config,
  libusb1,
  boost186,
  libpng,
  libarchive,
  httplib,
  openssl,
  protobuf_21,
  cproto,
  eigen,
  yaml-cpp,
  jsoncpp,
  spdlog,
  argparse,
  nlohmann_json,
  libnop,
  mcap,
  websocketpp,
  mp4v2,
  neargye-semver,
  backward-cpp,
  pcl,
  git,
  catch2_3,
  xtensor,
  bzip2,
  lz4,
  xz,
  apriltag,
  xlink,
  magic-enum,
  nanorpc,
  fp16,
  curl,
  cpr,
  xtl,
  fmt,
  zlib,
  depthai-data,
  ws-protocol,
  gcc-unwrapped,
}:

let
  arch = builtins.elemAt (builtins.split "-" stdenv.hostPlatform.system) 0;

  catch2_3WithSharedLibs = catch2_3.overrideAttrs (oldAttrs: {
    cmakeFlags = (oldAttrs.cmakeFlags or [ ]) ++ [
      "-DBUILD_SHARED_LIBS=ON"
    ];
  });

  # Latest commits are not compatible, use older version
  ws-protocolCompat = ws-protocol.overrideAttrs (old: {
    src = fetchFromGitHub {
      owner = "foxglove";
      repo = "ws-protocol";
      rev = "e8440dbc988efb42ad206fd3e2e46f4eb2e5f5c0";
      hash = "sha256-jPFSN2edGE0ge8AWFvIeXfoXn9JcAcLOTfsBcJq+dUo=";
    };

    patches = [ ./001-Ws-protocol-add-missing-libs.patch ];
  });

  prefixVar = "\${" + "prefix}";
  # Latest commits are not compatible, use older version
  xtensorCompat = xtensor.overrideAttrs (old: {

    src = fetchFromGitHub {
      owner = "xtensor-stack";
      repo = "xtensor";
      rev = "8ef0ee649fcd7476242af1d2072b45364036937d";
      hash = "sha256-qxOgaa0tIojlqxJxW00SUPRZp7gBJA0dLyQ3ToNk2Os=";
    };

    preConfigure = ''
      echo "Fixing xtensor.pc.in for Nix compatibility..."
      find . -name xtensor.pc.in -exec sed -i 's|${prefixVar}/@CMAKE_INSTALL_LIBDIR@|@CMAKE_INSTALL_FULL_LIBDIR@|g' {} \;
    '';
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
    enableGtk2 = true; # For GTK2 support
    enableGtk3 = true; # For GTK3 support
  };

  pyOpencv4WithGtk = python3Packages.opencv4.override {
    enableGtk2 = true; # For GTK2 support
    enableGtk3 = true; # For GTK3 support
  };

  rerun_sdk = fetchzip {
    url = "https://github.com/rerun-io/rerun/releases/download/0.16.1/rerun_cpp_sdk.zip";
    hash = "sha256-tYwcRjlU8m+OHkwdbQeM+X5outF0NFbj8Ee3y5h9+l0=";
    stripRoot = false; # Important for zip files to preserve the directory structure
  };

  #samplesLib = pkgs.callPackage ./samples.nix { };

  inherit (python3Packages)
    numpy
    mypy
    docformatter
    pybind11
    pybind11-stubgen
    ;
in

args:

stdenv.mkDerivation (rec {
  pname = "depthai-core";
  version = "3.0.0-rc.2";

  src = fetchFromGitHub {
    owner = "luxonis";
    repo = "depthai-core";
    tag = "v${version}";
    hash = "sha256-UjFxTXZ1j82OlEyw32Syr1QmGsA/Kd6VmRn7CsAO82A=";
    fetchSubmodules = true;
  };

  patches = [
    # Offine build
    (fetchpatch {
      url = "https://github.com/luxonis/depthai-core/pull/1303/commits/be1345a499219e87223d7911e3c0541bf01a319b.patch";
      hash = "sha256-xSPd1yog0VH8ZY1PupyCVRD90/kDWADP+HN7n6So+Jg=";
    })
    # CMake system install and fix RPATH
    (fetchpatch {
      url = "https://github.com/luxonis/depthai-core/pull/1309/commits/3caf449df59ea245797f4363da53149ef2978897.patch";
      hash = "sha256-J2NrGjWMeH4ks9cSfa+vtm4UTRM7Wp//0F/q+u/aKCs=";
    })

    ./0001-cmake-download-FWP-file-if-enabled.patch
    ./0001-cmake-fix-path-to-xtensor-include.patch
    ./0001-xtensor-python.patch

    ./0001-nixos-specific-patches.patch
    ./0002-cmake-Add-option-to-enable-3rdparty-dependencies.patch

    ./0004-fetch.patch
  ];

  nativeBuildInputs = [
    cmake
    clang-tools
    git
    pkg-config
  ];

  buildInputs =
    [
      gcc-unwrapped.lib
      argparse
      boost186
      libusb1.dev
      libpng
      magic-enum
      httplib
      openssl
      protobuf_21
      cproto
      xtl
      nlohmann_json
      catch2_3WithSharedLibs
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
      nanorpc
      curl.dev
      mp4v2
      pcl
      eigen
      xtensorCompat
      jsoncpp
      fmt
      mcap
      libarchive
      bzip2
      lz4
      xz
      zlib
      depthai-data
      ws-protocolCompat
    ]
    ++ lib.optional (args.enableOpencv or true) (
      opencv4.override {
        enableGtk2 = true;
        enableGtk3 = true;
      }
    );

  propagatedBuildInputs =
    [ ]
    ++ (
      if args.buildPython or false then
        with python3Packages;
        [
          numpy
          pybind11
        ]
      else
        [ ]
    );

  cmakeFlags = [
    (lib.cmakeBool "DEPTHAI_ENABLE_LIBUSB" true)
    (lib.cmakeBool "DEPTHAI_XLINK_LOCAL" false)
    (lib.cmakeBool "DEPTHAI_FETCH_ARTIFACTS" false)
    (lib.cmakeBool "DEPTHAI_ENABLE_3RDPARTY" false)
    (lib.cmakeBool "DEPTHAI_ENABLE_FW_DOWNLOAD" false)
    (lib.cmakeFeature "rerun_sdk_DIR" "${rerun_sdk}")
    (lib.cmakeFeature "CMAKE_INCLUDE_PATH" "include/3rdparty")
    (lib.cmakeBool "DEPTHAI_BOOTSTRAP_VCPKG" false)
    (lib.cmakeBool "BUILD_SHARED_LIBS" true)
    (lib.cmakeBool "DEPTHAI_PCL_SUPPORT" true)
    (lib.cmakeBool "DEPTHAI_XTENSOR_SUPPORT" true)
    (lib.cmakeBool "DEPTHAI_XTENSOR_EXTERNAL" true)
    (lib.cmakeBool "DEPTHAI_JSON_EXTERNAL" true)
    (lib.cmakeBool "DEPTHAI_LIBNOP_EXTERNAL" true)
    (lib.cmakeBool "DEPTHAI_ENABLE_MP4V2" false)

    # NOTE: Does not have CMake file under /lib
    (lib.cmakeBool "DEPTHAI_ENABLE_CURL" false)

    # NOTE: Not yet packaged
    (lib.cmakeBool "DEPTHAI_BASALT_SUPPORT" false)

    # NOTE: MR to fix the broken package
    (lib.cmakeBool "DEPTHAI_RTABMAP_SUPPORT" false)

    (lib.cmakeBool "DEPTHAI_BUILD_PYTHON" (args.buildPython or false))
    (lib.cmakeBool "DEPTHAI_BUILD_EXAMPLES" (args.enableExamples or false))
    (lib.cmakeBool "DEPTHAI_BUILD_TESTS" (args.enableTests or false))
    (lib.cmakeBool "DEPTHAI_ENABLE_LIBUSB" true)
    (lib.cmakeBool "DEPTHAI_FETCH_ARTIFACTS" false)
    (lib.cmakeBool "DEPTHAI_ENABLE_3RDPARTY" false)
    (lib.cmakeBool "BUILD_SHARED_LIBS" true)
    (lib.cmakeBool "DEPTHAI_INSTALL" true)
    (lib.cmakeBool "DEPTHAI_PCL_SUPPORT" (args.enableOpencv or true))
    (lib.cmakeBool "DEPTHAI_XTENSOR_SUPPORT" (args.enableOpencv or true))
    (lib.cmakeBool "DEPTHAI_ENABLE_BACKWARD" (args.enableOpencv or true))
    (lib.cmakeBool "DEPTHAI_OPENCV_SUPPORT" (args.enableOpencv or true))
  ];

  postPatch =
    if stdenv.isDarwin then
      ''
        name=$(basename $TMP)
        mkdir -p /tmp/$name/source/build/resources
        cp ${depthai-data}/share/resources/* /tmp/$name/source/build/resources
        rm include/3rdparty -rf
        rm 3rdparty -rf
      ''
    else
      ''
        mkdir -p /build/source/build/resources
        cp ${depthai-data}/share/resources/* /build/source/build/resources
        rm include/3rdparty -rf
        rm 3rdparty -rf
      '';

  meta = {
    description = "DepthAI core library variant";
    homepage = "https://github.com/luxonis/depthai-core";
    license = lib.licenses.mit;
    platforms = lib.platforms.all;
  };
})
