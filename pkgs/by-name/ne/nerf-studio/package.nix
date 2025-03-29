{ lib
, stdenv
, fetchFromGitHub
, python3Packages
, cudaPackages
, opencv
#, poetry-core
#, setuptools
}:

let
  python = python3Packages.python;
in
stdenv.mkDerivation (finalAttrs: {
  pname = "nerf-studio";
  version = "0.3.4";

  src = fetchFromGitHub {
    owner = "nerfstudio-project";
    repo = "nerfstudio";
    rev = "v${finalAttrs.version}";
    hash = "sha256-q4VgAKv9CaRsLLeJWdgUm1sigM5b47xJRN6ju4xLXM0=";
  };

  nativeBuildInputs = [
    python
    #poetry-core
    #setuptools
    cudaPackages.cudatoolkit
  ];

  buildInputs = with python3Packages; [
    # Core dependencies
    pip
    numpy
    torch-bin
    torchvision-bin
    torchaudio-bin
    scipy
    opencv
    
    # NeRF Studio specific dependencies
    imageio
    matplotlib
    tensorboard
    typing-extensions
    rich
    #tyro
    
    # Rendering and graphics
    ninja
    pyrender
    trimesh
    
    # Machine learning and computation
    wandb
    kornia
    
    # Misc utilities
    pytest
    #lightning

  ];

#  propagatedBuildInputs = finabuildInputs;

  # Use poetry to manage dependencies
  buildPhase = ''
    ${python}/bin/python -m pip install --no-cache-dir --disable-pip-version-check .
  '';

  installPhase = ''
    ${python}/bin/python -m pip install --no-cache-dir --disable-pip-version-check --prefix=$out .
  '';

  # Optional: Add tests if needed
  checkPhase = ''
    ${python}/bin/python -m pytest
  '';

  meta = {
    description = "A modern framework for neural radiance field (NeRF) research and development";
    homepage = "https://github.com/nerfstudio-project/nerfstudio";
    license = lib.licenses.mit;
    platforms = lib.platforms.linux;
    maintainers = with lib.maintainers; [ phodina ];
  };
})
