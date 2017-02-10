/* 
 - Deploy VPC 
 - Create subnets and gws
 - Create jump node
 - Create a master node in public-subnet
 - Create two minions node in private-subnet
*/

module "kube-vpc" {
   source = "../modules"
   azs = ["us-west-1b","us-west-1c"]
   vpc_cidr = "${var.vpc_cidr}"
   public_sub_cidr = "${var.public_sub_cidr}"
   private_sub_cidr = "${var.private_sub_cidr}"
   enable_dns_hostnames = false
   vpc_name = "Faizan-vpc"
}

// Bastion-node 
resource "aws_security_group" "jump-sg" {
   name = "jump-sg"
   vpc_id = "${module.kube-vpc.vpc_id}"
   
   ingress {
      from_port = 22
      to_port = 22 
      protocol = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
   }

   egress {
   from_port = 0
   to_port = 0 
   protocol = "-1"
   cidr_blocks = ["0.0.0.0/0"]
   }
}

//assgin eip to jump-node
resource "aws_eip" "default" {
   instance = "${aws_instance.jump_node.id}"
   vpc      = true
}

resource "aws_instance" "jump_node" {
    ami = "${lookup(var.amis_jump,var.region)}"
    instance_type = "t2.micro"
    key_name = "${var.aws_key_name}"
    vpc_security_group_ids = ["${aws_security_group.jump-sg.id}"]
    count = "${length(var.public_sub_cidr)}"
    subnet_id = "${element(module.kube-vpc.aws_pub_subnet_id,count.index)}"
    associate_public_ip_address = true
    source_dest_check = false

    tags = {
      Name = "Jump-node"
    }


}

// Master node in public subnet
resource "aws_security_group" "kube-master-sg" {
   name = "Kube-master"
   vpc_id = "${module.kube-vpc.vpc_id}"

   ingress {
      from_port = 22
      to_port = 22
      protocol = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
   }

   egress {
   from_port = 0
   to_port = 0
   protocol = "-1"
   cidr_blocks = ["0.0.0.0/0"]
   }
}


resource "aws_instance" "kube-master" {
    ami = "${lookup(var.amis_ubuntu,var.region)}"
    instance_type = "t2.micro"
    key_name = "${var.aws_key_name}"
    vpc_security_group_ids = ["${aws_security_group.kube-master-sg.id}"]
    #count = "${length(var.public_sub_cidr)}"
    count = "${var.pub_inst_count}"
    subnet_id = "${element(module.kube-vpc.aws_pub_subnet_id,count.index)}"
    associate_public_ip_address = true
    source_dest_check = false

    tags = {
      Name = "kube-master-node"
    }

}

//Etcd nodes
resource "aws_security_group" "etcd-ins" {
   name = "etcd-private"
   vpc_id = "${module.kube-vpc.vpc_id}"

   ingress {
      from_port = 0
      to_port = 0
      protocol = "-1"
      cidr_blocks = ["${var.vpc_cidr}"]
   }

   egress {
   from_port = 0
   to_port = 0
   protocol = "-1"
   cidr_blocks = ["0.0.0.0/0"]
   }
}

resource "aws_instance" "etcd-ins" {
    ami = "${lookup(var.amis_ubuntu,var.region)}"
    instance_type = "t2.micro"
    key_name = "${var.aws_key_name}"
    vpc_security_group_ids = ["${aws_security_group.etcd-ins.id}"]
    count = "${var.etcd_inst_count}"
    subnet_id = "${element(module.kube-vpc.aws_pri_subnet_id,count.index)}"
    associate_public_ip_address = false
    source_dest_check = false
    tags = {
      Name = "etcd-node-${count.index}"
    }
}



// Worker nodes in private subnet
resource "aws_security_group" "private-ins" {
   name = "private"
   vpc_id = "${module.kube-vpc.vpc_id}"

   ingress {
      from_port = 22
      to_port = 22
      protocol = "tcp"
      cidr_blocks = ["${var.vpc_cidr}"]
   }

   egress {
   from_port = 0
   to_port = 0
   protocol = "-1"
   cidr_blocks = ["0.0.0.0/0"]
   }
}


resource "aws_instance" "private-ins" {
    ami = "${lookup(var.amis_ubuntu,var.region)}"
    instance_type = "t2.micro"
    key_name = "${var.aws_key_name}"
    vpc_security_group_ids = ["${aws_security_group.private-ins.id}"]
    count = "${var.pri_inst_count}"
    subnet_id = "${element(module.kube-vpc.aws_pri_subnet_id,count.index)}"
    associate_public_ip_address = false
    source_dest_check = false
    tags = {
      Name = "private-node-${count.index}"
    }



}

