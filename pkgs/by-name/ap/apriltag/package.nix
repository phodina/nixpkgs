{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  python3Packages,
}:

let
  opencv4WithGtk = python3Packages.opencv4.override {
    enableGtk2 = true; # For GTK2 support
    enableGtk3 = true; # For GTK3 support
  };
in
stdenv.mkDerivation (finalAttrs: {
  pname = "apriltags";
  version = "3.4.3";

  src = fetchFromGitHub {
    owner = "AprilRobotics";
    repo = "AprilTags";
    tag = "v${finalAttrs.version}";
    hash = "sha256-1XbsyyadUvBZSpIc9KPGiTcp+3G7YqHepWoORob01Ss=";
  };

  nativeBuildInputs = [
    cmake
  ];

  buildInputs = [ opencv4WithGtk ];

  cmakeFlags = [ "-DBUILD_EXAMPLES=ON" ];

  doCheck = true;

  meta = {
    description = "Visual fiducial system popular for robotics research";
    homepage = "https://april.eecs.umich.edu/software/apriltag";
    license = lib.licenses.bsd2;
    platforms = lib.platforms.all;
    maintainers = with lib.maintainers; [ phodina ];
  };
})
