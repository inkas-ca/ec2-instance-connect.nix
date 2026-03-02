{
  stdenvNoCC,
  lib,
  fetchFromGitHub,
  makeWrapper,
  coreutils,
  openssl,
  curl,
  gnugrep,
  gnused,
  logger,
  gawk,
  findutils,
  runCommand,
  cacert,
}:

let
  amazon-ca-bundle = runCommand "amazon-ca-bundle" { } ''
    mkdir -p $out/etc/ssl/certs
    awk '
      BEGIN { keep=0 }
      /Amazon Root CA [0-9]+/ { keep=1 }
      /END CERTIFICATE/ {
        if (keep) print
        keep=0
        next
      }
      keep { print }
    ' ${cacert}/etc/ssl/certs/ca-bundle.crt > $out/etc/ssl/certs/amazon-ca-bundle.crt
  '';
in
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
    sed -i "s%/usr/bin/%%g" src/bin/*
    sed -i "s%^/bin/%%g" src/bin/*
    sed -i "s%\([^\#][^\!]\)/bin/%\1%g" src/bin/*
  '';

  installPhase = ''
    runHook preInstall

    mkdir $out
    cp -r src/bin $out

    runHook postInstall
  '';

  postFixup = ''
    substituteInPlace $out/bin/eic_curl_authorized_keys --replace-fail 'ca_path=/etc/ssl/certs' 'ca_path=${amazon-ca-bundle}/etc/ssl/certs/amazon-ca-bundle.crt'

    for f in $out/bin/*; do
      wrapProgram $f --prefix PATH : ${
        lib.makeBinPath [
          coreutils
          openssl
          curl
          gnugrep
          gnused
          logger
          gawk
          findutils
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
