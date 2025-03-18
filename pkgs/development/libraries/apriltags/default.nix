{ lib
, stdenv
, fetchFromGitHub
, cmake
, opencv
, python3
}:

stdenv.mkDerivation rec {
  pname = "AprilTags";
  version = "3.4.3";

  src = fetchFromGitHub {
    owner = "AprilRobotics";
    repo = "AprilTags";
    tag = "v${version}";
    sha256 = "sha256-1XbsyyadUvBZSpIc9KPGiTcp+3G7YqHepWoORob01Ss=";
  };

  nativeBuildInputs = [
    cmake
    python3
  ];

  buildInputs = [
    opencv
  ];

  propagatedBuildInputs = [
    python3.pkgs.numpy
  ];

  cmakeFlags = [
    "-DBUILD_EXAMPLES=ON"
  ];

  doCheck = true;

  meta = with lib; {
    description = "Header-only library for conversion to/from half-precision floating point formats";
    homepage = "https://github.com/Maratyszcza/FP16";
    license = licenses.mit;
    platforms = platforms.all;
    maintainers = with maintainers; [ /* add your name here */ ];
  };
}

