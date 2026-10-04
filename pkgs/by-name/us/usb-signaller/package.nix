{
  lib,
  fetchFromGitea,
  rustPlatform,
  pkg-config,
  makeWrapper,
  udev,
  systemd,
  coreutils,
  networkmanager,
  net-tools,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "usb-signaller";
  version = "0.4.2";

  src = fetchFromGitea {
    domain = "codeberg.org";
    owner = "DylanVanAssche";
    repo = "usb-signaller";
    tag = "v${finalAttrs.version}";
    hash = "sha256-c4wI6sHHiCad18t62dD9SEgdmoo0S+BO22wUGytIJ0Q=";
  };

  cargoHash = "sha256-cmsxh7ZjU4z2LvwsnqZNlS5P9aeL05eZrg+mPDR9ShQ=";

  nativeBuildInputs = [
    pkg-config
    makeWrapper
  ];
  buildInputs = [ udev ];

  # These tests assume a writable, non-sandboxed sysfs-like path
  checkFlags = [
    "--skip=sysfs::tests::mkdir_path_already_exists"
    "--skip=sysfs::tests::symlink_destination_path_already_exists"
  ];

  postPatch = ''
    substituteInPlace src/service.rs \
      --replace-fail /usr/bin/systemctl ${systemd}/bin/systemctl
    substituteInPlace distro/scripts/*.sh \
      --replace-quiet /usr/bin/systemctl ${systemd}/bin/systemctl
  '';

  postInstall = ''
    install -Dm644 com.meego.usb_moded.conf \
      $out/share/dbus-1/system.d/com.meego.usb_moded.conf

    install -Dm644 usb-signaller.service \
      $out/lib/systemd/system/usb-signaller.service
    substituteInPlace $out/lib/systemd/system/usb-signaller.service \
      --replace-fail /usr/bin/usb-signaller $out/bin/usb-signaller

    for mode in mtp tethering developer; do
      install -Dm755 distro/scripts/usb-signaller-$mode-mode.sh \
        $out/bin/usb-signaller-$mode-mode
      wrapProgram $out/bin/usb-signaller-$mode-mode \
        --prefix PATH : ${
          lib.makeBinPath [
            coreutils
            networkmanager
            net-tools
          ]
        }
      install -Dm644 distro/systemd/usb-signaller-$mode-mode.service \
        $out/lib/systemd/system/usb-signaller-$mode-mode.service
      substituteInPlace $out/lib/systemd/system/usb-signaller-$mode-mode.service \
        --replace-fail "=usb-signaller-$mode-mode" "=$out/bin/usb-signaller-$mode-mode"
    done
  '';

  meta = {
    description = "Replacement for usb-moded on mainline Linux mobile devices";
    homepage = "https://codeberg.org/DylanVanAssche/usb-signaller";
    license = lib.licenses.gpl3Plus;
    mainProgram = "usb-signaller";
    maintainers = with lib.maintainers; [ phodina ];
    platforms = lib.platforms.linux;
  };
})
