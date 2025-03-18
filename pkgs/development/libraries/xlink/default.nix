{ lib
, stdenv
, fetchFromGitHub
, cmake
, pkg-config
, libusb1
}:

stdenv.mkDerivation rec {
  pname = "xlink";
  version = "0.0.0-unstable-2024-10-10";

  src = fetchFromGitHub {
    owner = "luxonis";
    repo = "XLink";
    #rev = "2b517e1cb1ca77bea17679f9fdeb739812431174";
    rev = "7f5633ab542df632acaf4ccaf5e98d30f984e6e4";
    sha256 = "sha256-jZQhH4xZgwM/439GkOr28Xrh1D18vh3jMPiRJR8WdD0=";
  };

  patches = [
  #  ./001-remove-hunter.patch
    ./002-remove-hunter.patch
  ];

  nativeBuildInputs = [
    cmake
    pkg-config
  ];

  buildInputs = [
    libusb1
  ];

  cmakeFlags = [
    "-DXLINK_ENABLE_LIBUSB=ON"
    "-DCMAKE_BUILD_TYPE=Release"
  ];

  # Install headers
  postInstall = ''
    mkdir -p $out/include
    cp -r $src/include/* $out/include/
  '';

  meta = with lib; {
    description = "XLink library for communication with Myriad VPUs";
    homepage = "https://github.com/luxonis/XLink";
    license = licenses.asl20; # Apache License 2.0
    platforms = platforms.all;
    maintainers = with maintainers; [ /* add your name here */ ];
  };
}
