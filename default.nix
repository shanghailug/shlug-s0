{ mkDerivation, stdenv, base, yesod, wai,
  aeson, text, time, directory, random,
  network, sockaddr, strict
}:
mkDerivation {
  pname = "shlug-s0";
  version = "0.1.0.0";
  src = ./.;
  isLibrary = false;
  isExecutable = true;
  executableHaskellDepends = [ base yesod aeson text time strict
                               directory random network sockaddr ];
  license = stdenv.lib.licenses.gpl3;
}
