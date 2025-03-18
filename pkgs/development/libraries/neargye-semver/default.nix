{ lib
, stdenv
, fetchFromGitHub
, cmake
, pkg-config
}:

stdenv.mkDerivation rec {
  pname = "neargye-semver";
  version = "0.3.1";

  src = fetchFromGitHub {
    owner = "Neargye";
    repo = "semver";
    tag = "v${version}";
    sha256 = "sha256-0HOp+xzo8xcCUUgtSh87N9DXP5P0odBaYXhcDzOiiXE=";
  };

  nativeBuildInputs = [
    cmake
    pkg-config
  ];

  buildInputs = [
  ];

  cmakeFlags = [
    "-DCMAKE_BUILD_TYPE=Release"
  ];

  # Install headers
  postInstall = ''
    mkdir -p $out/include
    cp -r $src/include/* $out/include/
  '';

  meta = with lib; {
    description = "C++17 header-only dependency-free versioning library complying with Semantic Versioning 2.0.0";
    homepage = "https://github.com/Neargye/semver";
    license = licenses.mit; # MIT License
    platforms = platforms.all;
    maintainers = with maintainers; [ /* add your name here */ ];
  };
}
