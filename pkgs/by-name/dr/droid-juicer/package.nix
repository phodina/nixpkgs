{
  lib,
  rustPlatform,
  fetchCrate,
  systemd,
  nix-update-script,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "droid-juicer";
  version = "0.4.2";

  src = fetchCrate {
    inherit (finalAttrs) pname version;
    hash = "sha256-ydLwnHQf4k3X4JUFZdxau2XTX7B2rkrX7s0+s/S3qCU=";
  };

  cargoHash = "sha256-lzdSTaviOKCpwOFbt1c7neRw5dDDfmSWYBP2Bb37TCc=";

  nativeBuildInputs = [ rustPlatform.bindgenHook ];

  postPatch = ''
    # The per-device configs are read from a hardcoded FHS path
    substituteInPlace src/main.rs \
      --replace-fail "/usr/share/droid-juicer/configs" "$out/share/droid-juicer/configs"

    substituteInPlace droid-juicer.service \
      --replace-fail "/usr/bin/droid-juicer" "$out/bin/droid-juicer" \
      --replace-fail "/usr/sbin/reboot" "${lib.getExe' systemd "systemctl"} reboot" \
      --replace-fail 'ExecStartPre=-/usr/bin/plymouth display-message --text="Extracting binary firmware..."' ""
  '';

  postInstall = ''
    install -Dm644 configs/*.toml -t $out/share/droid-juicer/configs
    install -Dm644 droid-juicer.service -t $out/lib/systemd/system
  '';

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Extract firmware from Android vendor partitions";
    homepage = "https://gitlab.com/mobian1/droid-juicer";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ phodina ];
    platforms = lib.platforms.linux;
    mainProgram = "droid-juicer";
  };
})
