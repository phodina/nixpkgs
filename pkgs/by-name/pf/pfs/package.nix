{
  lib,
  stdenv,
  fetchFromGitLab,
  rustPlatform,
  cargo,
  rustc,
  meson,
  ninja,
  pkg-config,
  gettext,
  glib,
  desktop-file-utils,
  wrapGAppsHook4,
  gtk4,
  libadwaita,
  nix-update-script,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "pfs";
  version = "0.1.2";

  src = fetchFromGitLab {
    domain = "gitlab.gnome.org";
    owner = "World/Phosh";
    repo = "pfs";
    tag = "v${finalAttrs.version}";
    hash = "sha256-LIwWSNYIYAKt61Iot8ltrfmEWsLX1qCn+ry117vaM9o=";
  };

  cargoDeps = rustPlatform.fetchCargoVendor {
    inherit (finalAttrs) pname version src;
    hash = "sha256-AHnrwx56sfNoyHRILcmZ1em86bQ7mC0ALcu2nR6EgHE=";
  };

  nativeBuildInputs = [
    cargo
    rustc
    rustPlatform.cargoSetupHook
    meson
    ninja
    pkg-config
    gettext
    glib
    desktop-file-utils
    wrapGAppsHook4
  ];

  buildInputs = [
    gtk4
    libadwaita
  ];

  doCheck = true;

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "File selector widget and file-open service for Phosh";
    homepage = "https://gitlab.gnome.org/World/Phosh/pfs";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ phodina ];
    mainProgram = "pfs-open";
    platforms = lib.platforms.linux;
  };
})
