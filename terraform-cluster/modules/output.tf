output "vpc_id" {
  value = "${aws_vpc.m_vpc.id}"
}

output "aws_pub_subnet_id" {
  value = ["${aws_subnet.public-subnet.*.id}"]
}

output "aws_pri_subnet_id" {
  value = ["${aws_subnet.private-subnet.*.id}"]
}
