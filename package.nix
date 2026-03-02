{
  stdenvNoCC,
  lib,
  fetchFromGitHub,
  makeWrapper,
  coreutils,
  openssl,
  curl,
  gnugrep,
}:

stdenvNoCC.mkDerivation rec {
  pname = "ec2-instance-connect";
  version = "1.1.17";

  src = fetchFromGitHub {
    owner = "aws";
    repo = "aws-ec2-instance-connect-config";
    tag = version;
    sha256 = "XXrVcmgsYFOj/1cD45ulFry5gY7XOkyhmDV7yXvgNhI=";
  };

  nativeBuildInputs = [ makeWrapper ];

  postPatch = ''
    # Dump /bin, /usr/bin, etc from binary paths names since we want to use $PATH on Ubuntu/etc
    sed -i "s%/usr/bin/%%g" src/bin/*
    sed -i "s%^/bin/%%g" src/bin/*
    sed -i "s%\([^\#][^\!]\)/bin/%\1%g" src/bin/*
    patchShebangs src/bin/*
  '';

  installPhase = ''
    runHook preInstall

    mkdir $out
    cp -r src/bin $out

    runHook postInstall
  '';

  postFixup = ''
    for f in $out/bin/*; do
      wrapProgram $f --prefix PATH : ${
        lib.makeBinPath [
          coreutils
          openssl
          curl
          gnugrep
        ]
      }
    done
  '';

  meta = with lib; {
    description = "This is the ssh daemon configuration and necessary EC2 instance scripting to enable EC2 Instance Connect. Also included is various package manager configurations for packaging for various Linux distributions.";
    license = licenses.asl20;
    platforms = platforms.linux;
    maintainers = with maintainers; [ samuel-martineau ];
    mainProgram = "eic_run_authorized_keys";
  };
}
