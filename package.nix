{
  stdenvNoCC,
  lib,
  fetchFromGitHub,
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

  installPhase = ''
    runHook preInstall

    mkdir $out
    cp -r src/bin $out

    runHook postInstall
  '';

  meta = with lib; {
    description = "This is the ssh daemon configuration and necessary EC2 instance scripting to enable EC2 Instance Connect. Also included is various package manager configurations for packaging for various Linux distributions.";
    license = licenses.asl20;
    platforms = platforms.linux;
    maintainers = with maintainers; [ samuel-martineau ];
    mainProgram = "eic_run_authorized_keys";
  };
}
