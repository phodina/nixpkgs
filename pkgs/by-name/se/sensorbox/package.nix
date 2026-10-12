{
  lib,
  fetchFromGitLab,
  rustPlatform,
  pkg-config,
  wrapGAppsHook4,
  gtk4,
  libadwaita,
  nix-update-script,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "sensorbox";
  version = "0.1.1-unstable-2026-09-22";

  src = fetchFromGitLab {
    owner = "solderchef";
    repo = "sensorbox";
    rev = "c296378bbf252ba580e655f8d01a44d1a77305b5";
    hash = "sha256-rXwXY2bqDraqr8wSJCkeKYFBF3iL81Sr2WILFgseUSA=";
  };

  # Upstream does not commit a Cargo.lock
  postPatch = ''
    ln -s ${./Cargo.lock} Cargo.lock
  '';

  cargoLock.lockFile = ./Cargo.lock;

  nativeBuildInputs = [
    pkg-config
    wrapGAppsHook4
  ];

  buildInputs = [
    gtk4
    libadwaita
  ];

  passthru.updateScript = nix-update-script { extraArgs = [ "--version=branch" ]; };

  meta = {
    description = "Linux sensor recorder with IIO and Qualcomm SSC backends";
    homepage = "https://gitlab.com/solderchef/sensorbox";
    license = lib.licenses.gpl3Plus;
    mainProgram = "sensorbox";
    platforms = lib.platforms.linux;
  };
})
