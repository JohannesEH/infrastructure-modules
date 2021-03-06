data "aws_ami" "eks-worker" {
  filter {
    name   = "name"
    values = ["amazon-eks-node-${var.cluster_version}-*"]
  }

  most_recent = true
  owners      = ["602401143452"] # Amazon Account ID
}

# EKS currently documents this required userdata for EKS worker nodes to
# properly configure Kubernetes applications on the EC2 instance.
# We utilize a Terraform local here to simplify Base64 encoding this
# information into the AutoScaling Launch Configuration.
# More information: https://docs.aws.amazon.com/eks/latest/userguide/launch-workers.html
locals {
  worker-node-userdata = <<USERDATA
#!/bin/sh
set -o xtrace
/etc/eks/bootstrap.sh --apiserver-endpoint '${var.eks_endpoint}' --b64-cluster-ca '${var.eks_certificate_authority}' '${var.cluster_name}'

echo fs.inotify.max_user_watches=${var.worker_inotify_max_user_watches} | sudo tee -a /etc/sysctl.conf
sudo sysctl -p
USERDATA


  worker-node-userdata-cw-agent = <<USERDATA
#!/bin/sh
set -o xtrace
/etc/eks/bootstrap.sh --apiserver-endpoint '${var.eks_endpoint}' --b64-cluster-ca '${var.eks_certificate_authority}' '${var.cluster_name}'

echo fs.inotify.max_user_watches=${var.worker_inotify_max_user_watches} | sudo tee -a /etc/sysctl.conf
sudo sysctl -p

mkdir /var/cloudwatch/

wget https://s3.amazonaws.com/amazoncloudwatch-agent/amazon_linux/amd64/latest/amazon-cloudwatch-agent.rpm -P /var/cloudwatch
sudo rpm -U /var/cloudwatch/amazon-cloudwatch-agent.rpm

sudo aws s3 cp s3://${var.cloudwatch_agent_config_bucket} /var/cloudwatch/ --recursive
sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -a fetch-config -m ec2 -c file:/var/cloudwatch/${var.cloudwatch_agent_config_file} -s
USERDATA

}

resource "aws_launch_configuration" "eks" {
  associate_public_ip_address = true
  name_prefix                 = var.cluster_name
  iam_instance_profile        = aws_iam_instance_profile.eks.name
  image_id                    = data.aws_ami.eks-worker.id
  instance_type               = var.worker_instance_type
  security_groups             = var.security_groups
  user_data_base64            = var.cloudwatch_agent_enabled ? base64encode(local.worker-node-userdata-cw-agent) : base64encode(local.worker-node-userdata)
  key_name                    = var.ec2_ssh_key

  root_block_device {
    volume_size = var.worker_instance_storage_size
    volume_type = "gp2"
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "eks" {
  name                 = var.cluster_name
  desired_capacity     = var.worker_instance_min_count
  launch_configuration = aws_launch_configuration.eks.id
  min_size             = var.worker_instance_min_count
  max_size             = var.worker_instance_max_count
  vpc_zone_identifier  = var.subnet_ids

  # The following can be set in case of the default health check are not sufficient
  #health_check_grace_period = 5
  #default_cooldown = 15

  tag {
    key                 = "Name"
    value               = "eks-${var.cluster_name}-worker"
    propagate_at_launch = true
  }

  tag {
    key                 = "kubernetes.io/cluster/${var.cluster_name}"
    value               = "owned"
    propagate_at_launch = true
  }
}

