{
  lib,
  fetchPypi,
  python3Packages,
  nix-update-script,
}:

python3Packages.buildPythonApplication (finalAttrs: {
  pname = "ofonoctl";
  version = "0.4.1";
  pyproject = true;

  src = fetchPypi {
    inherit (finalAttrs) pname version;
    hash = "sha256-ZLsJvpt89ZMY4P+eRt/OEnx9vpBXQ38Y/VTWxoS0D3o=";
  };

  build-system = with python3Packages; [ setuptools ];

  dependencies = with python3Packages; [
    dbus-python
    tabulate
  ];

  pythonImportsCheck = [ "ofonoctl" ];

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Test/control application for the ofono daemon";
    homepage = "https://git.sr.ht/~martijnbraam/ofonoctl";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ phodina ];
    mainProgram = "ofonoctl";
    platforms = lib.platforms.linux;
  };
})
