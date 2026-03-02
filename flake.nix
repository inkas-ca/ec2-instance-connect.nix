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
      forEachSupportedSystem = f: nixpkgs.lib.genAttrs supportedSystems (system: f system);
    in
    {
      packages = forEachSupportedSystem (
        system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
        in
        rec {
          ec2-instance-connect = pkgs.callPackage ./package.nix { };
          default = ec2-instance-connect;
        }
      );

      overlays = rec {
        ec2-instance-connect = final: _prev: {
          ec2-instance-connect = self.packages.${final.system}.ec2-instance-connect;
        };
        default = ec2-instance-connect;
      };

      nixosModules = rec {
        ec2-instance-connect = {
          nixpkgs.overlays = [ self.overlays.default ];
          imports = [ ./module.nix ];
        };
        default = ec2-instance-connect;
      };
    };
}
