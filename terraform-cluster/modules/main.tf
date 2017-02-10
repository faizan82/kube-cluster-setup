/**********************************************
 This will deploy one vpc with a public subnet,
 2 private subnets,
 igw,
 nat-gateway,
 associated route tables
**********************************************/

resource "aws_vpc" "m_vpc" {
   cidr_block = "${var.vpc_cidr}"
   enable_dns_hostnames = "${var.enable_dns_hostnames}"
   tags = {
        Name = "${var.vpc_name}"
   }
}


/**************** Public-subnet **********/
resource "aws_subnet" "public-subnet" {
   // Make AZ variable
   #availability_zone = "us-west-1b"
   count = "${length(var.public_sub_cidr)}"
   availability_zone = "${element(var.azs,count.index)}"
   cidr_block = "${var.public_sub_cidr[count.index]}"
   vpc_id = "${aws_vpc.m_vpc.id}"
   tags = {
        Name = "Public_Subnet"
   }
}


/********* Private-subnet ***************/

resource "aws_subnet" "private-subnet" {
   // Creating multile private subnets for now
   count = "${length(var.private_sub_cidr)}"
   availability_zone = "${element(var.azs,count.index)}"
   cidr_block = "${var.private_sub_cidr[count.index]}"
   vpc_id = "${aws_vpc.m_vpc.id}"
   tags = {
        Name = "Private_Subnet"
   }
}



/***** Routing information ***************/

resource "aws_route_table" "pub_rtb" {
   vpc_id = "${aws_vpc.m_vpc.id}"
   route {
     cidr_block = "0.0.0.0/0"
     gateway_id ="${aws_internet_gateway.igw.id}"
   }
   tags = {
     Name = "Public-RTB"
   }
}

resource "aws_route_table_association" "a-pub-sub" {
   subnet_id = "${aws_subnet.public-subnet.id}"
   route_table_id = "${aws_route_table.pub_rtb.id}"

}

resource "aws_route_table" "pri_rtb" {
   vpc_id = "${aws_vpc.m_vpc.id}"
   route {
     cidr_block = "0.0.0.0/0"
     gateway_id ="${aws_nat_gateway.ngw.id}"
   }
   tags = {
     Name = "Private-RTB"
   }
}


resource "aws_route_table_association" "a-priv-sub" {
   count = "${length(var.private_sub_cidr)}"
   subnet_id = "${element(aws_subnet.private-subnet.*.id,count.index)}"
   route_table_id = "${element(aws_route_table.pri_rtb.*.id,count.index)}"
}


/* Nat-Gateway */
resource "aws_eip" "nat"{
   vpc = true
}

resource "aws_nat_gateway" "ngw" {
    allocation_id = "${aws_eip.nat.id}"
    subnet_id = "${aws_subnet.public-subnet.id}"
    depends_on = ["aws_internet_gateway.igw"]
}

/* Internet-Gateways */

resource "aws_internet_gateway" "igw" {
   vpc_id = "${aws_vpc.m_vpc.id}"
   tags = {
        Name = "igw-pub-sub"
   }
}
