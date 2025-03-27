{ lib
, stdenv
, fetchFromGitHub
, cmake
, pkg-config
, opencv
, pcl
, eigen
, boost
, sqlite
, zlib
, wrapQtAppsHook
, qt5
, vtk_9
, libpcap
, libusb1
, freenect
, librealsense
}:

let
  vtk_9_withQt5 = vtk_9.override { enableQt = true; };
in
stdenv.mkDerivation (finalAttrs: {
  pname = "rtabmap";
  version = "0.21.4";

  src = fetchFromGitHub {
    owner = "introlab";
    repo = "rtabmap";
    rev = "${finalAttrs.version}";
    hash = "sha256-HrIATYRuhFfTlO4oTRZo7CM30LFVyatZJON31Fe4HTQ=";
  };

  postPatch = ''
  substituteInPlace corelib/src/CameraThread.cpp \
    --replace "pcl/io/io.h" "pcl/common/io.h"
'';

  nativeBuildInputs = [
    cmake
    wrapQtAppsHook
    pkg-config
  ];

  buildInputs = [
    opencv
    pcl
    eigen
    boost
    libpcap
    sqlite
    zlib
    qt5.qtbase
    qt5.qtsvg
    vtk_9_withQt5
    libusb1
    freenect
    librealsense
  ];

  patches = [ ./001-Fix-Cmake-vtk.patch ];

  cmakeFlags = [
    (lib.cmakeBool "BUILD_EXAMPLES=OFF" false)
    (lib.cmakeBool "WITH_QT" true)
    (lib.cmakeFeature "VTK_QT_VERSION"  "5")
    (lib.cmakeBool "WITH_TORCH" true)
    (lib.cmakeBool "WITH_PYTHON" true)
    (lib.cmakeBool "BUILD_APP" true)
    (lib.cmakeBool "BUILD_GUI" true)
  ];

  meta = {
    description = "Real-Time Appearance-Based Mapping";
    homepage = "https://github.com/introlab/rtabmap";
    license = lib.licenses.bsd3;
    platforms = lib.platforms.unix;
    maintainers = with lib.maintainers; [ phodina ];
  };
})
