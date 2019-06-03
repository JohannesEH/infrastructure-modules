# resource "aws_launch_template" "eks-workers" {
#   name = "${var.cluster_name}"

#   block_device_mappings {
#     device_name = "/dev/sda1"

#     ebs {
#       volume_size = "${var.worker_instance_storage_size}"
#     }
#   }

#   # capacity_reservation_specification {
#   #   capacity_reservation_preference = "open"
#   # }

#   # credit_specification {
#   #   cpu_credits = "standard"
#   # }

#   disable_api_termination = false

#   ebs_optimized = true

#   # elastic_gpu_specifications {
#   #   type = "test"
#   # }

#   # elastic_inference_accelerator {
#   #   type = "eia1.medium"
#   # }

#   iam_instance_profile {
#     name = "${aws_iam_instance_profile.eks.name}"
#   }

#   image_id = "${data.aws_ami.eks-worker.id}"

#   instance_initiated_shutdown_behavior = "terminate"

#   instance_market_options {
#     market_type = "spot"
#   }

#   instance_type = "${var.worker_instance_type}"

#   # kernel_id = "test"

#   # key_name = "test"

#   # license_specification {
#   #   license_configuration_arn = "arn:aws:license-manager:eu-west-1:123456789012:license-configuration:lic-0123456789abcdef0123456789abcdef"
#   # }

#   monitoring {
#     enabled = true
#   }

#   network_interfaces {
#     associate_public_ip_address = false
#     # subnet_id  = "subnet-0c79d9aa4cfd01399"
#     security_groups = ["${aws_security_group.eks-node.id}"]
#   }

#   # placement {
#   #   availability_zone = "us-west-2a"
#   # }

#   # ram_disk_id = "test"

#   vpc_security_group_ids = ["${aws_security_group.eks-node.id}"]

#   tag_specifications {
#     resource_type = "instance"

#     tags = {
#       Name = "eks-${var.cluster_name}-worker"
#       "kubernetes.io/cluster/${var.cluster_name}" = "owned"
#     }
#   }

#   user_data = "${base64encode(local.worker-node-userdata)}"
# }

resource "aws_launch_template" "eks-workers" {
  name_prefix   = "${var.cluster_name}"
  image_id      = "${data.aws_ami.eks-worker.id}"
  instance_type = "${var.worker_instance_type}"

    tag_specifications {
    resource_type = "instance"

    tags = {
      Name = "pelle-of-doom-eks-${var.cluster_name}-worker"
      "kubernetes.io/cluster/coke" = "owned"
    }
  }

  instance_market_options {
    market_type = "spot"
  }

  network_interfaces {
    associate_public_ip_address = true
    subnet_id = "subnet-0c79d9aa4cfd01399"
    security_groups = ["${aws_security_group.eks-node.id}"]
  }

  key_name = "${aws_key_pair.eks-node.key_name}"
  iam_instance_profile {
    name = "${aws_iam_instance_profile.eks.name}"
  } 

  user_data = "${base64encode(local.worker-node-userdata-spot)}"
}

resource "aws_autoscaling_group" "eks-worker" {
  availability_zones = ["eu-west-1a"]
  desired_capacity   = "${var.worker_instance_min_count}"
  max_size           = "${var.worker_instance_max_count}"
  min_size           = "1"

  name_prefix = "pelle-of-doom-eks-${var.cluster_name}-worker"

  launch_template {
    id      = "${aws_launch_template.eks-workers.id}"
    #version = "$Latest"
    version = "${aws_launch_template.eks-workers.latest_version}"
  }

  tag = {
   key = "k8s.io/cluster-autoscaler/enabled"
   value = ""
    propagate_at_launch = true
  }

  tag = {
    key = "k8s.io/cluster-autoscaler/coke"
    value = ""
    propagate_at_launch = true
  }

  lifecycle {
    create_before_destroy = true
  }
}

locals {
  worker-node-userdata-spot = <<USERDATA
#!/bin/sh
set -o xtrace
/etc/eks/bootstrap.sh --apiserver-endpoint '${var.eks_endpoint}' --b64-cluster-ca '${var.eks_certificate_authority}' '${var.cluster_name}' --kubelet-extra-args '--node-labels=lifecycle=Ec2Spot --register-with-taints=spotInstance=true:PreferNoSchedule'
USERDATA
}
