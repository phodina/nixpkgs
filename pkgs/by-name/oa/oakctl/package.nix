{
  lib,
  stdenv,
  fetchurl,
  patchelf,
  glibc,
}:

let
  version = "0.2.12";

  # Note: Extracted from install script
  # https://oakctl-releases.luxonis.com/oakctl-installer.sh
  sources = {
    x86_64-linux = {
      url = "https://oakctl-releases.luxonis.com/data/${version}/linux_x86_64/oakctl";
      hash = "sha256-HCnFD0LD6sQp9k3SP2g4svjA5/kLvfrnN+IwiuMWGCY=";
    };
    aarch64-linux = {
      url = "https://oakctl-releases.luxonis.com/data/${version}/linux_aarch64/oakctl";
      hash = "sha256-1oJQs57/tW3rsMM+LAuKiBUf1aKOKFoPQAMcVUfXqlE=";
    };
    aarch64-darwin = {
      url = "https://oakctl-releases.luxonis.com/data/${version}/darwin_arm64/oakctl";
      hash = "sha256-arS2qfd/Z/ZCNWAKD9bc2PMwkhVtO5WViTibMST7zd8=";
    };
    x86_64-darwin = {
      url = "https://oakctl-releases.luxonis.com/data/${version}/darwin_x86_64/oakctl";
      hash = "sha256-yyvDQbFEtlB8xmdbxquy22wAIUcCSVchP/AuSpi4TAU=";
    };
  };

  nativeBuildInputs =
    if stdenv.isLinux then
      [
        patchelf
        glibc
      ]
    else
      [ ];

  source =
    sources.${stdenv.hostPlatform.system}
      or (throw "Unsupported platform: ${stdenv.hostPlatform.system}");
in
stdenv.mkDerivation (finalAttrs: {
  pname = "oakctl";
  inherit version;

  src = fetchurl {
    url = source.url;
    hash = source.hash;
  };

  inherit nativeBuildInputs;

  dontUnpack = true;
  dontConfigure = true;
  dontBuild = true;

  postPatch =
    if stdenv.isDarwin then
      ''
        mkdir -p $out/bin

        # Note: the $src points to store so it's immutable, also it's not writable after copy
        cp $src oakctl

        chmod +w oakctl
        install_name_tool -add_rpath $out/lib oakctl
        chmod -w+x oakctl

        cp oakctl $out/bin/oakctl
      ''
    else
      ''
        mkdir -p $out/bin

        # Note: the $src points to store so it's immutable, also it's not writable after copy
        cp $src oakctl

        chmod +w oakctl

        patchelf --set-interpreter ${glibc}/lib/ld-linux-x86-64.so.2 oakctl
        patchelf --set-rpath $out/lib oakctl

        chmod -w+x oakctl

        cp oakctl $out/bin/oakctl
      '';

  # Note: The command 'oakctl self-update' won't work as the binary is located in the nix/store
  meta = {
    description = "oakctl CLI tool for Luxonis devices";
    homepage = "https://rvc4.docs.luxonis.com/software/tools/oakctl";
    # Note: Should it be redistributable?
    license = lib.licenses.unfree;
    platforms = lib.platforms.all;
    mainProgram = "oakctl";
    maintainers = with lib.maintainers; [ phodina ];
  };
})
