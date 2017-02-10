/* 
 Variables for deploying stack
*/


region = "us-west-1"
vpc_cidr = "10.2.0.0/16"
pub_inst_count = 3
pri_inst_count = 3
etcd_inst_count = 3
public_sub_cidr = ["10.2.0.0/24"]
private_sub_cidr = ["10.2.1.0/24","10.2.2.0/24"]


amis_aws = {
    us-east-2 = "ami-e1e7bd84"
    us-west-1 = "ami-2abeed4a"
}

amis_centos = {

}

amis_ubuntu = {
    us-west-1 = "ami-539ac933"
}

amis_coreos = {

}

amis_jump = {
    us-west-1 = "ami-539ac933"
}
