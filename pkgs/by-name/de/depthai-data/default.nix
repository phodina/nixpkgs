{ lib
, stdenv
, fetchFromGitHub
}:

stdenv.mkDerivation rec {
  pname = "depthai-data";
  version = "3.0.0-alpha.14";

  src = fetchFromGitHub {
    owner = "phodina";
    repo = "depthai-data";
    rev = "v${version}";
    sha256 = "sha256-myNBYWyQifQf+hyCKpLGS01iW/oRrb5tzW6dQqZbCHg=";
  };

  # No build phase needed, this is just data
  dontBuild = true;

  installPhase = ''
    mkdir -p $out/share/resources
    cp -r * $out/share/resources/
    rm $out/share/resources/README.md

    # Copy license if it exists
    if [ -f LICENSE ]; then
      cp LICENSE $out/share/resources/
    fi
  '';

  meta = with lib; {
    description = "DepthAI camera calibration and neural network data files";
    homepage = "https://github.com/phodina/depthai-data";
    license = licenses.mit;
    platforms = platforms.all;
    maintainers = with maintainers; [ ];
  };
}
