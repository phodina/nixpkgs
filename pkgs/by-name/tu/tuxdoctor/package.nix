{
  lib,
  fetchFromGitLab,
  rustPlatform,
  pkg-config,
  wrapGAppsHook4,
  makeWrapper,
  libcamera,
  alsa-lib,
  gtk4,
  libadwaita,
  openssl,
  systemd,
  modemmanager,
  bluez,
  libinput,
  glib,
  nix-update-script,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "tuxdoctor";
  version = "0.1.0-unstable-2026-03-11";

  src = fetchFromGitLab {
    owner = "tuxdoctor";
    repo = "tuxdoctor";
    rev = "05f3a1ec900ee82feb19549a028b7ca455f1b75e";
    hash = "sha256-6pfWG7AmSX3udhwTFSuwLWJ1i+10/pDiaehIC9wRgu8=";
  };

  # Upstream does not commit a workspace Cargo.lock
  postPatch = ''
    ln -s ${./Cargo.lock} Cargo.lock

    substituteInPlace core/src/device_config.rs \
      --replace-fail "/usr/share/tuxdoctor/configs" "$out/share/tuxdoctor/configs"
  '';

  cargoLock.lockFile = ./Cargo.lock;

  buildFeatures = [ "tuxdoctor-ui/gtk" ];

  nativeBuildInputs = [
    pkg-config
    rustPlatform.bindgenHook
    wrapGAppsHook4
  ];

  buildInputs = [
    libcamera
    alsa-lib
    gtk4
    libadwaita
    openssl
  ];

  # The tests shell out to system tools and talk to hardware
  doCheck = false;

  postInstall = ''
    install -Dm644 configs/*.json -t $out/share/tuxdoctor/configs
    install -Dm644 packaging/99-tuxdoctor-input.rules -t $out/lib/udev/rules.d
    install -Dm644 packaging/desktop/tuxdoctor.png \
      $out/share/icons/hicolor/256x256/apps/tuxdoctor.png
  '';

  preFixup = ''
    gappsWrapperArgs+=(
      --prefix PATH : ${
        lib.makeBinPath [
          systemd
          modemmanager
          bluez
          libinput
          glib
        ]
      }:$out/bin
    )
  '';

  passthru.updateScript = nix-update-script { extraArgs = [ "--version=branch" ]; };

  meta = {
    description = "Hardware diagnostic tool for mobile Linux phones and tablets";
    homepage = "https://gitlab.com/tuxdoctor/tuxdoctor";
    license = lib.licenses.gpl2Only;
    maintainers = with lib.maintainers; [ phodina ];
    mainProgram = "tuxdoctor-cli";
    platforms = lib.platforms.linux;
  };
})
