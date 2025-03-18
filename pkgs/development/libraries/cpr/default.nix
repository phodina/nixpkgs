{ lib
, stdenv
, fetchFromGitHub
, cmake
, pkg-config
, openssl_3
, curl
, zlib
, gtest
, cppcheck
}:

stdenv.mkDerivation rec {
  pname = "cpr";
  version = "1.11.0";

  src = fetchFromGitHub {
    owner = "libcpr";
    repo = "cpr";
    tag = "${version}";
    sha256 = "sha256-jWyss0krj8MVFqU1LAig+4UbXO5pdcWIT+hCs9DxemM=";
  };

  nativeBuildInputs = [
    cmake
    pkg-config
    gtest
    cppcheck
  ];

  buildInputs = [
    openssl_3
    zlib
    curl
  ];

  cmakeFlags = [
    # Does not build with CPPCHECK
    # "-DCPR_ENABLE_CPPCHECK=ON"
    "-DCPR_BUILD_TEST=ON"
    "-DCURL_ZLIB=OFF"
    "-DBUILD_SHARED_LIBS=ON"
    "-DCPR_USE_SYSTEM_CURL=ON"
    "-DCMAKE_BUILD_TYPE=Release"
  ];

  # Install headers
  postInstall = ''
    mkdir -p $out/include
    cp -r $src/include/* $out/include/
  '';

  meta = with lib; {
    description = "C++ Requests: Curl for People, a spiritual port of Python Requests";
    homepage = "https://github.com/libcpr/cpr";
    license = licenses.mit; # MIT License
    platforms = platforms.all;
    maintainers = with maintainers; [ /* add your name here */ ];
  };
}
