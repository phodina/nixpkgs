{ lib
, stdenv
, fetchFromGitHub
, cmake
, boost186
, openssl
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "nanorpc";
  version = "1.1.1";

  src = fetchFromGitHub {
    owner = "tdv";
    repo = "nanorpc";
    rev = "${finalAttrs.version}";
    hash = "sha256-wxCZdOJfWFB4V1aqGUeFrQPkF3I8r5d3p/kFs0bFq7E=";
  };

  nativeBuildInputs = [ cmake ];
  #buildInputs = [ boost186 openssl ];
  buildInputs = [ ];

  cmakeFlags = [
    "-DBUILD_EXAMPLES=OFF"  # Disable examples by default
    "-DBUILD_TESTS=OFF"     # Disable tests by default
    "-DNANORPC_PURE_CORE=ON"     # Skip Boost
    "-DNANORPC_WITH_SSL=OFF"     # Skip OpenSSL
  ];

  meta = {
    description = "NanoRPC - Modern C++ RPC library";
    homepage = "https://github.com/tdv/nanorpc";
    license = lib.licenses.mit;
    platforms = lib.platforms.all;
    maintainers = with lib.maintainers; [ phodina ];
  };
})
