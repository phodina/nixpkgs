{ lib
, stdenv
, fetchFromGitLab
, cmake
, doxygen
, apriltag
, pkg-config
, eigen
, git
, opencv4
, cli11
, tbb
, boost
, glog
, gflags
, magic-enum
, fmt
, python3
, libepoxy
, cereal
, ceres-solver
, nlohmann_json
, pangolin
, opengv
, libGL
, libtiff
, sophus
, bzip2
, lz4
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "basalt";
  # 0-unstable-2024-31-08
  version = "47b063e64fa7dd56ac04eb2d579c5cb5e72c743e";

  src = fetchFromGitLab {
    owner = "VladyslavUsenko";
    repo = "basalt";
    rev = "${finalAttrs.version}";
    hash = "sha256-+NM25e3gN7aBxqHeJcGHvqDuW3klZ28bvXifVihHuJk=";
    fetchSubmodules = true;
  };

  patches = [
    ./001-Fix-test-jacobian.patch
    ./002-fix-basalt-headers.patch
    #./003-cmake-Add-option-to-enable-build-of-third-party-depe.patch
    #./004-cmake-use-system-libs.patch
    #./005-apriltag-use-system.patch
  ];

  nativeBuildInputs = [
    cmake
    pkg-config
    doxygen
    git
  ];

  buildInputs = [
    apriltag
    eigen
    opencv4
    tbb
    boost
    glog
    gflags
    fmt
    libepoxy
    cereal
    ceres-solver
    nlohmann_json
    pangolin
    python3
    opengv
    libGL
    magic-enum
    cli11
    libtiff.out
    sophus
    bzip2
    lz4
  ];

  cmakeFlags = [
    (lib.cmakeBool "BUILD_EXAMPLES" true)
    (lib.cmakeBool "BUILD_THIRD_PARTY" false)
    #(lib.cmakeFeature "EIGEN3_INCLUDE_DIR" "${eigen}/include/eigen3")
    (lib.cmakeFeature "CMAKE_INCLUDE_PATH" "${eigen}/include/eigen3:${eigen}/include:${sophus}/include:$src/include:$src/include/basalt/utils")
  ];

  postPatch = ''
    #rm  -r thirdparty/{apriltag,ros,CLI11,opengv,Pangolin,magic_enum,json}

    # Modify CMakeLists.txt to add include directories
    sed -i '1i \
# Explicitly set include directories\
include_directories(\
  "'"$(pwd)/include"'"\
  "'"$(pwd)/thirdparty/basalt-headers/include"'"\
  "'"$(pwd)/thirdparty"'"\
  "'"$(pwd)/thirdparty/basalt-headers"'"\
  "'"$(pwd)/include/basalt"'"\
  "'"$(pwd)/include/basalt/utils"'"\
  "'"$(pwd)/include/basalt/imu"'"\
  "'"$(pwd)/thirdparty/ros/ros_comm/tools/rosbag/include"'"\
  "'"$(pwd)/thirdparty/ros/ros_comm/tools/rosbag_storage/include"'"\
  "'"$(pwd)/thirdparty/ros/roscpp_core/cpp_common/include"'"\
  "'"$(pwd)/thirdparty/ros/ros_comm/utilities/roslz4/include"'"\
  "'"$(pwd)/thirdparty/ros/roscpp_core/rostime/include"'"\
  "'"$(pwd)/thirdparty/ros/roscpp_core/roscpp_traits/include"'"\
  "'"$(pwd)/thirdparty/ros/roscpp_core/roscpp_serialization/include"'"\
  "'"$(pwd)/thirdparty/ros/console_bridge/include"'"\
  "'"$(pwd)/thirdparty/ros/include"'"\
  "'"$(pwd)/thirdparty/apriltag/include"'"\
  "'"$(pwd)/thirdparty/basalt-headers/thirdparty/eigen"'"\
  "'"${magic-enum}/include/magic_enum"'"\
  "'"${sophus}/include"'"\
  "'"${apriltag}/include/apriltag"'"\
)\
' ./CMakeLists.txt
  '';

#\
# Ensure Eigen and Sophus can be found\
#list(APPEND CMAKE_PREFIX_PATH "'"${eigen}"'" "'"${sophus}"'")\
#set(Eigen3_INCLUDE_DIRS "'"${eigen}/include/eigen3"'")\
#  "'"${eigen}/include/eigen3"'"\
#  "'"${eigen}/include"'"\

  meta = {
    description = "Visual-inertial mapping framework based on non-linear factor graph optimization";
    homepage = "https://github.com/VladyslavUsenko/basalt";
    license = lib.licenses.bsd3;
    platforms = lib.platforms.unix;
    maintainers = with lib.maintainers; [ phodina ];
  };
})
