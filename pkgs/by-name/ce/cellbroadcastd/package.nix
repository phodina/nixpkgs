{
  lib,
  stdenv,
  fetchFromGitLab,
  meson,
  ninja,
  pkg-config,
  vala,
  gobject-introspection,
  glib,
  gmobile,
  modemmanager,
  mobile-broadband-provider-info,
  nix-update-script,
}:

let
  # Derived from subprojects/gvdb.wrap
  gvdb = fetchFromGitLab {
    domain = "gitlab.gnome.org";
    owner = "GNOME";
    repo = "gvdb";
    rev = "4758f6fb7f889e074e13df3f914328f3eecb1fd3";
    hash = "sha256-4mqoHPlrMPenoGPwDqbtv4/rJ/uq9Skcm82pRvOxNIk=";
    # Workaround for https://github.com/NixOS/nixpkgs/issues/485701
    forceFetchGit = true;
  };
in

stdenv.mkDerivation (finalAttrs: {
  pname = "cellbroadcastd";
  version = "0.0.3";

  src = fetchFromGitLab {
    domain = "gitlab.freedesktop.org";
    owner = "devrtz";
    repo = "cellbroadcastd";
    tag = "v${finalAttrs.version}";
    hash = "sha256-QMx/E631aWJIwvRDbzyrO9K+7xdd54ZbiE4Eoune3Co=";
  };

  postPatch = ''
    cp -r ${gvdb} subprojects/gvdb
    chmod -R u+w subprojects/gvdb
  '';

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
    vala
    gobject-introspection
  ];

  buildInputs = [
    glib
    gmobile
    modemmanager
    mobile-broadband-provider-info
  ];

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Cell broadcast daemon for mobile Linux";
    homepage = "https://gitlab.freedesktop.org/devrtz/cellbroadcastd";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ phodina ];
    platforms = lib.platforms.linux;
  };
})
