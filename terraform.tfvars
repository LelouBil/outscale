region = "eu-west-2"
ip_range_net = "10.0.0.0/16"
ip_range_sub_priv = "10.0.0.0/24"
ip_range_sub_pub = "10.0.1.0/24"

web_image_id = "ami-7b8d1702"
web_vm_type = "tinav5.c1r1p3"


bastion_image_id = "ami-7b8d1702"
bastion_vm_type = "tinav5.c1r1p3"


web_vm_count = 2
load_balancer_name = "terraform-public-load-balancer"

