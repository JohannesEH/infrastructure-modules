variable "deploy" {
}

variable "cluster_name" {}

variable "subnet_ids" {
    type = "list"
}

variable "vpc_id" {}

variable "autoscaling_group_id" {}
