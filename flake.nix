{
  description = "This is the ssh daemon configuration and necessary EC2 instance scripting to enable EC2 Instance Connect. Also included is various package manager configurations for packaging for various Linux distributions.";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";

  outputs =
    { self, nixpkgs, ... }:
    let
      supportedSystems = [
        "x86_64-linux"
        "aarch64-linux"
      ];
      forEachSupportedSystem =
        f:
        nixpkgs.lib.genAttrs supportedSystems (
          system:
          f {
            pkgs = import nixpkgs { inherit system; };
          }
        );
    in
    {
      packages = forEachSupportedSystem (
        { pkgs }:
        rec {
          ec2-instance-connect = pkgs.callPackage ./package.nix { };
          default = ec2-instance-connect;
        }
      );

      nixosModules = rec {
        ec2-instance-connect =
          { pkgs, ... }@args:
          import ./module.nix {
            ec2-instance-connect = self.packages.${pkgs.system}.ec2-instance-connect;
          } args;
        default = ec2-instance-connect;
      };
    };
}
