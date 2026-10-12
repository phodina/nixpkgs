{
  lib,
  stdenv,
  fetchFromGitHub,
  unstableGitUpdater,
}:

stdenv.mkDerivation {
  pname = "pil-squasher";
  version = "0-unstable-2024-06-11";

  src = fetchFromGitHub {
    owner = "linux-msm";
    repo = "pil-squasher";
    rev = "3c9f8b8756ba6e4dbf9958570fd4c9aea7a70cf4";
    hash = "sha256-MEW85w3RQhY3tPaWtH7OO22VKZrjwYUWBWnF3IF4YC0=";
  };

  makeFlags = [ "prefix=${placeholder "out"}" ];

  passthru.updateScript = unstableGitUpdater { };

  meta = {
    description = "Squash split Qualcomm PIL firmware images (mdt + bXX) into a single mbn";
    homepage = "https://github.com/linux-msm/pil-squasher";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ phodina ];
    mainProgram = "pil-squasher";
    platforms = lib.platforms.linux;
  };
}
