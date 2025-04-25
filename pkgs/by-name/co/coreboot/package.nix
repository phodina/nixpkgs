{ lib
, stdenv
, fetchgit
, pkgsCross
, flex
, bison
, ncurses
, python3
, perl
, git
, zlib
, writeText
, gcc
, cmocka
, cmake
, meson
, ninja
, curl
, openssl
, pkg-config
, acpica-tools
, libusb1
, gnat
, makeWrapper
, buildPackages
}:

stdenv.mkDerivation rec {
  pname = "coreboot";
  version = "24.12";

  src = fetchgit {
    url = "https://review.coreboot.org/coreboot.git";
    rev = version;
    hash = "sha256-PtHvzMf9sKvrgWVT5XVCy4BbMklCKcpnJAE+WeE2Cgs=";
  };

  nativeBuildInputs = [
    flex
    bison
    ncurses
    python3
    perl
    git
    pkg-config
    cmake
    meson
    ninja
    curl
    makeWrapper
  ];

  buildInputs = [
    zlib
    openssl
    libusb1
    cmocka
    acpica-tools
    gcc
    gnat # For Ada compiler
  ];

  # Create a basic config file
  # This is a placeholder - user should create their own config for their specific motherboard
  configFile = writeText "coreboot-defconfig" ''
    CONFIG_VENDOR_EMULATION=y
    CONFIG_BOARD_EMULATION_QEMU_X86_Q35=y
    CONFIG_PAYLOAD_SEABIOS=y
    CONFIG_CONSOLE_SERIAL=y
  '';

  prePatch = ''
    # Make build reproducible
    substituteInPlace Makefile --replace "-O2" "-O2 -no-pie"
    substituteInPlace Makefile --replace "build-id" "build-id=none"
  '';

  configurePhase = ''
    # Copy our basic config, or use the user's if provided via configFile
    cp ${configFile} .config
    
    # Optional: Update config with provided platformConfig if specified
    make olddefconfig
  '';

  buildPhase = ''
    make -j$NIX_BUILD_CORES
  '';

  installPhase = ''
    mkdir -p $out/bin $out/share/coreboot
    
    # Install the coreboot ROM image
    cp build/coreboot.rom $out/share/coreboot/
    
    # Install utilities
    for util in $(find util -type f -executable -not -path "*/\.*"); do
      if [ -f "$util" ]; then
        install -Dm755 $util $out/bin/$(basename $util)
      fi
    done
    
    # Install important build tools
    for tool in cbfstool ifdtool; do
      if [ -f "build/$tool/$tool" ]; then
        install -Dm755 build/$tool/$tool $out/bin/$tool
      fi
    done
  '';

  # Create a wrapper for convenience
  postInstall = ''
    # Create a simple wrapper to flash the ROM (this would need to be customized)
    makeWrapper ${libusb1}/bin/flashrom $out/bin/flash-coreboot \
      --add-flags "-w $out/share/coreboot/coreboot.rom"

    # Install documentation
    mkdir -p $out/share/doc
    cp -r Documentation $out/share/doc/coreboot
  '';

  meta = with lib; {
    description = "Open Source firmware for x86 and other architectures";
    homepage = "https://www.coreboot.org/";
    license = licenses.gpl2;
    platforms = platforms.x86_64 ++ platforms.i686;
    maintainers = with maintainers; [ ];
  };
}

