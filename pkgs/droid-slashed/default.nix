with import <nixpkgs> {};

stdenv.mkDerivation rec {
  name = "font-droid-sans-mono-slashed";
  src = fetchurl {
    url = "http://www.cosmix.org/software/files/DroidSansMonoSlashed.zip";
    sha256 = "71768814dc4de0ea6248d09a2d2285bd47e9558f82945562eb78487c71348107";
  };

  phases = [ "unpackPhase" "installPhase" ];
  sourceRoot = "./";

  unpackCmd = ''
    unzip $curSrc
  '';

  installPhase = ''
    mkdir -p $out/share/fonts/droid-sans-mono-slashed
    cp *.ttf $out/share/fonts/droid-sans-mono-slashed
  '';

  buildInputs = [ unzip ];
}
