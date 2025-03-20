{ lib
, stdenv
, fetchFromGitHub
, cmake
, pkg-config
, boost186
, libwebsockets
, nlohmann_json
, websocketpp
, openssl
, zlib
}:

stdenv.mkDerivation rec {
  pname = "ws-protocol";
  #version = "1.4.0";
  version = "e8440dbc988efb42ad206fd3e2e46f4eb2e5f5c0";

  src = fetchFromGitHub {
    owner = "foxglove";
    repo = "ws-protocol";
    rev = "${version}"; 
    sha256 = "sha256-jPFSN2edGE0ge8AWFvIeXfoXn9JcAcLOTfsBcJq+dUo=";
  };

  nativeBuildInputs = [
    cmake
    pkg-config
  ];

  buildInputs = [
    boost186
    libwebsockets
    websocketpp
    nlohmann_json
    openssl
    zlib
  ];

  sourceRoot = "${src.name}/cpp/foxglove-websocket";

  cmakeFlags = [
    "-DBUILD_SHARED_LIBS=ON"
  ];

postInstall = ''
    # Create pkgconfig directory if it doesn't exist
    mkdir -p $out/lib/pkgconfig
    
    # Create the .pc file
    cat > $out/lib/pkgconfig/foxglove-websocket.pc << EOF
Name: foxglove-websocket
Description: Foxglove WebSocket Protocol Implementation
Version: ${version}
Requires: 
Libs: -L$out/lib -lfoxglove_websocket
Cflags: -I$out/include
EOF
    
    # Create CMake config directories
    mkdir -p $out/lib/cmake/foxglove-websocket
    
    # Create foxglove-websocketConfig.cmake
    cat > $out/lib/cmake/foxglove-websocket/foxglove-websocketConfig.cmake << EOF
# foxglove-websocket CMake configuration file

# Compute installation prefix relative to this file
get_filename_component(_IMPORT_PREFIX "\''${CMAKE_CURRENT_LIST_DIR}/../../.." ABSOLUTE)

# Define the imported target
add_library(foxglove::websocket SHARED IMPORTED)

# Set target properties
set_target_properties(foxglove::websocket PROPERTIES
  INTERFACE_INCLUDE_DIRECTORIES "\''${_IMPORT_PREFIX}/include"
  IMPORTED_LOCATION "\''${_IMPORT_PREFIX}/lib/libfoxglove_websocket.so"
)

# Cleanup
unset(_IMPORT_PREFIX)
EOF
    
    # Create foxglove-websocketConfigVersion.cmake
    cat > $out/lib/cmake/foxglove-websocket/foxglove-websocketConfigVersion.cmake << EOF
set(PACKAGE_VERSION "${version}")

# Check whether the requested version is compatible
if("\''${PACKAGE_VERSION}" VERSION_LESS "\''${PACKAGE_FIND_VERSION}")
  set(PACKAGE_VERSION_COMPATIBLE FALSE)
else()
  set(PACKAGE_VERSION_COMPATIBLE TRUE)
  if("\''${PACKAGE_VERSION}" VERSION_EQUAL "\''${PACKAGE_FIND_VERSION}")
    set(PACKAGE_VERSION_EXACT TRUE)
  endif()
endif()
EOF
  '';

  meta = with lib; {
    description = "WebSocket protocol implementation";
    homepage = "https://github.com/foxglove/ws-protocol";  # Update with actual URL
    license = licenses.mit;  # Update with actual license
    platforms = platforms.all;
    maintainers = with maintainers; [ ];
  };
}

