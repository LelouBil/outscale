variable "access_key_id" {
  type = string
  sensitive = true
}

variable "secret_key_id" {
  type = string
  sensitive = true
}

variable "bastion_image_id" {type = string}
variable "bastion_vm_type" {type = string}


variable "load_balancer_name" {type = string}

variable "web_vm_type" {type = string}
variable "web_image_id" {type = string}
variable "web_vm_count" {type = number}


variable "region" {type = string}

variable "ip_range_net" { type = string}
variable "ip_range_sub_pub" { type = string}
variable "ip_range_sub_priv" { type = string}


