{
  pkgs,
  config,
  lib,
  ...
}:
{
  options.services.ec2-instance-connect = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Whether to enable EC2 Instance Connect.";
    };

    package = lib.mkOption {
      type = lib.types.package;
      default = pkgs.ec2-instance-connect;
      defaultText = lib.literalExpression "pkgs.ec2-instance-connect";
      description = "EC2 Instance Connect package to use.";
    };

    user = lib.mkOption {
      type = lib.types.str;
      default = "ec2-instance-connect";
      description = "User to run the EC2 Instance Connect authorized keys command as.";
    };

    group = lib.mkOption {
      type = lib.types.str;
      default = "ec2-instance-connect";
      description = "Group for the EC2 Instance Connect user.";
    };
  };

  config =
    let
      cfg = config.services.ec2-instance-connect;
    in
    lib.mkIf cfg.enable {
      environment.etc."ssh/authorized_keys_command" = {
        mode = "0555";
        text = ''
          #!/bin/sh
          exec ${lib.getExe cfg.package} "$@"
        '';
      };

      services.openssh = {
        authorizedKeysCommand = "/etc/ssh/authorized_keys_command %u %f";
        authorizedKeysCommandUser = cfg.user;
      };

      users = {
        groups."${cfg.group}" = { };

        users."${cfg.user}" = {
          isSystemUser = true;
          description = "User for EC2 Instance Connect";
          group = cfg.group;
        };
      };
    };
}
