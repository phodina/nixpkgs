{ lib
, stdenv
, fetchFromGitHub
, cmake
, python3
, gtest
, gbenchmark
}:

stdenv.mkDerivation rec {
  pname = "fp16";
  version = "1.0.0-unstable-2023-10-13";

  src = fetchFromGitHub {
    owner = "Maratyszcza";
    repo = "FP16";
    rev = "98b0a46bce017382a6351a19577ec43a715b6835";
    sha256 = "sha256-aob776ZGjnH4k/xfsdIcN9+wiuDreUoRBpyzrWGuxKk=";
  };

#  patches = [
#    ./001-use-nix-gtest-gbenchmark.patch
#  ];

  nativeBuildInputs = [
    cmake
    python3
    gtest
    gbenchmark
  ];

  cmakeFlags = [
    "-DFP16_BUILD_TESTS=OFF"
    "-DFP16_BUILD_BENCHMARKS=OFF"
    "-DFP16_USE_SYSTEM_LIBS=ON"
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
