# Mandatory arguments

variable "cluster_name" {
  type        = string
  description = "Name of the EKS Cluster."
}

variable "node_group_name" {
  type        = string
  description = "Name of the EKS Node Group."
}

variable "node_role_arn" {
  type        = string
  description = "IAM Role ARN that provides permissions for the EKS Node Group."
}

variable "subnet_ids" {
  type        = list(string)
  description = "Identifiers of EC2 Subnets to associate with the EKS Node Group. These subnets must have the following resource tag: kubernetes.io/cluster/CLUSTER_NAME (where CLUSTER_NAME is replaced with the name of the EKS Cluster)."
}

variable "gpu_ami" {
  type    = bool
  default = false
  description = "Type of AMI associated with the EKS Node Group. False: AL2_x86_64. True: AL2_x86_64_GPU."
}


# Scaling config

variable "desired_size" {
  type    = number
  default = 0
}

variable "min_size" {
  type    = number
  default = 0
}

variable "max_size" {
  type    = number
  default = 0
}


# Remote access config

variable "ec2_ssh_key" {
  type        = string
  description = "EC2 Key Pair name that provides access for SSH communication with the worker nodes in the EKS Node Group."
}

# variable "source_security_group_ids" {
#   type        = list(string)
#   description = "Set of EC2 Security Group IDs to allow SSH access (port 22) from on the worker nodes."
# }


# Optional arguments

variable "disk_size" {
  type        = number
  default     = 20
  description = "Disk size in GiB for worker nodes. Defaults to 20."

}

variable "instance_types" {
  type        = list(string)
  default     = ["t3.medium"]
  description = "Set of instance types associated with the EKS Node Group. Currently, the EKS API only accepts a single value in the set."
}

variable "force_update_version" {
  type        = bool
  default     = false
  description = "Force version update if existing pods are unable to be drained due to a pod disruption budget issue."
}
