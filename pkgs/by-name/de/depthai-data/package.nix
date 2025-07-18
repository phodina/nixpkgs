{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "depthai-data";
  # DepthAI v3.0.0-rc.2
  version = "v3_rc";

  src = fetchFromGitHub {
    owner = "phodina";
    repo = "depthai-data";
    rev = "49b7cd75402e72de860c4e5888dae896d3f7c9bc";
    hash = "sha256-NRPWCmPlhIOjhnOO9e5hLYLSgAJejPpBGfxp6QaUcc8=";
  };

  # No build phase needed, this is just data
  dontBuild = true;

  installPhase = ''
    mkdir -p $out/share/resources
    cp -r * $out/share/resources/
    rm $out/share/resources/README.md
  '';

  meta = {
    description = "DepthAI camera calibration and neural network data files";
    homepage = "https://github.com/phodina/depthai-data";
    license = lib.licenses.mit;
    platforms = lib.platforms.all;
    maintainers = with lib.maintainers; [ phodina ];
  };
})
