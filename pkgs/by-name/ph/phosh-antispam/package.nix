{
  lib,
  stdenv,
  fetchFromGitLab,
  meson,
  ninja,
  pkg-config,
  gettext,
  wrapGAppsHook4,
  desktop-file-utils,
  appstream-glib,
  libxml2,
  gtk4,
  libadwaita,
  nix-update-script,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "phosh-antispam";
  version = "3.5";

  src = fetchFromGitLab {
    domain = "gitlab.com";
    owner = "kop316";
    repo = "phosh-antispam";
    tag = finalAttrs.version;
    hash = "sha256-tyhOmgWDXXZHmGbaGcRLjVdsXITBpRVJ2GoAMJR8mss=";
    # Workaround for https://github.com/NixOS/nixpkgs/issues/485701
    forceFetchGit = true;
  };

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
    gettext
    wrapGAppsHook4
    desktop-file-utils
    appstream-glib
    libxml2
  ];

  buildInputs = [
    gtk4
    libadwaita
  ];

  doCheck = true;

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Call antispam daemon and preferences app for Phosh";
    homepage = "https://gitlab.com/kop316/phosh-antispam";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ phodina ];
    platforms = lib.platforms.linux;
    mainProgram = "phosh-antispam";
  };
})
