{ lib
, stdenv
, fetchFromGitHub
, cmake
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
, cereal
, ceres-solver
, pangolin
, opengv
, libtiff
, sophus
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "basalt";
  # 0-unstable-2023-25-01
  version = "9656344fa138df1f5b86135ded5433e6fb45151a";

  src = fetchFromGitHub {
    owner = "VladyslavUsenko";
    repo = "basalt";
    rev = "${finalAttrs.version}";
    hash = "sha256-memZAwhD+AZl5y9BgRzsRVl9vmAw5WJzCsVaRwyESKU=";
    fetchSubmodules = true;
  };

  patches = [
    ./001-Fix-linked-libraries.patch
    ./002-Fix-gtest.patch
  ];

  postPatch = ''
    rm  -r thirdparty/{apriltag,ros,CLI11,opengv,Pangolin,magic_enum,json}
'';

  nativeBuildInputs = [
    cmake
    pkg-config
    git
  ];

  buildInputs = [
    eigen
    opencv4
    tbb
    boost
    glog
    gflags
    fmt
    cereal
    ceres-solver
    pangolin
    python3
    opengv
    magic-enum
    cli11
    libtiff
    sophus
  ];

  cmakeFlags = [
    (lib.cmakeBool "BUILD_TESTS" false)
    (lib.cmakeBool "BUILD_EXAMPLES" true)
    (lib.cmakeFeature "EIGEN3_INCLUDE_DIR" "${eigen}/include/eigen3")
  ];
# FIXME: Add to the CMAKE
# find_package(Eigen3 REQUIRED)
# include_directories(${EIGEN3_INCLUDE_DIR})

  meta = {
    description = "Visual-inertial mapping framework based on non-linear factor graph optimization";
    homepage = "https://github.com/VladyslavUsenko/basalt";
    license = lib.licenses.bsd3;
    platforms = lib.platforms.unix;
    maintainers = with lib.maintainers; [ phodina ];
  };
})
