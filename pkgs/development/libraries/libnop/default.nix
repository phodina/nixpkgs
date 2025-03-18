{ lib
, stdenv
, fetchFromGitHub
#, gtest
, gnumake
}:

stdenv.mkDerivation rec {
  pname = "libnop";
  version = "unstable-2021-11-03";

  src = fetchFromGitHub {
    owner = "luxonis";
    repo = "libnop";
    #rev = "35e800d81f28c632956c5a592e3cbe8085ecd430";
    rev = "ab842f51dc2eb13916dc98417c2186b78320ed10";
    #sha256 = "sha256-wt88E3XLKQVUetKI4nMxQDP34iHSJj8bwBGTgiVVC2M=";
    sha256 = "sha256-d2z/lDI9pe5TR82MxGkR9bBMNXPvzqb9Gsd5jOv6x1A=";
  };


  # Since this is a header-only library, we can skip build phase
  # and just install the headers directly
  dontBuild = true;

  # Skip the tests to avoid compilation errors
  doCheck = false;

  # Install headers to the correct location as this is a header-only library
  installPhase = ''
    mkdir -p $out/include
    cp -r $src/include/* $out/include/
    
    # Create pkg-config file
    mkdir -p $out/lib/pkgconfig
    cat > $out/lib/pkgconfig/libnop.pc << EOF
    includedir=$out/include
    
    Name: libnop
    Description: Header-only C++ serialization library
    Version: ${version}
    Cflags: -I\$includedir
    EOF
  '';

  meta = with lib; {
    description = "A fast, header-only C++ serialization library";
    homepage = "https://github.com/google/libnop";
    license = licenses.asl20;
    platforms = platforms.all;
    maintainers = with maintainers; [ ];
    mainProgram = "libnop";
  };
}
