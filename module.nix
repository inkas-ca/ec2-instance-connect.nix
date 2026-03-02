{ ec2-instance-connect }:
{
  config,
  lib,
  ...
}:
{
  options.ec2-instance-connect = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Whether to enable EC2 Instance Connect.";
    };

    package = lib.mkOption {
      type = lib.types.package;
      default = ec2-instance-connect;
      defaultText = lib.literalExpression "ec2-instance-connect";
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

  config = lib.mkIf config.ec2-instance-connect.enable {
    services.openssh = {
      authorizedKeysCommand = "${lib.getExe config.ec2-instance-connect.package} %u %f";
      authorizedKeysCommandUser = config.ec2-instance-connect.user;
    };

    users = {
      groups."${config.ec2-instance-connect.group}" = { };

      users."${config.ec2-instance-connect.user}" = {
        isSystemUser = true;
        description = "User for EC2 Instance Connect";
        group = config.ec2-instance-connect.group;
      };
    };
  };
}
