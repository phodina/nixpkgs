{ lib
, stdenv
, fetchFromGitHub
, cmake
, boost186
, openssl
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "nanorpc";
  version = "1.1.0";

  src = fetchFromGitHub {
    owner = "luxonis";
    repo = "nanorpc";
    rev = "${finalAttrs.version}";
    hash = "sha256-EFwk+O3HUgGTP8IGGJcbhf0D22WoqQm80iWbphOO6aQ=";
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
