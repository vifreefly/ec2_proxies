provider "aws" {
  version = "~> 2.7"
  access_key = "${var.AWS_ACCESS_KEY_ID}"
  secret_key = "${var.AWS_SECRET_ACCESS_KEY}"
  region = "${var.AWS_DEFAULT_REGION}"
}

resource "aws_security_group" "ec2_proxies_sg" {
  name = "ec2_proxies_sg"

  # Open up incoming ssh port
  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Open up outbound internet access
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Open up incoming traffic for proxy
  ingress {
    from_port   = "${var.PROXY_PORT}"
    to_port     = "${var.PROXY_PORT}"
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# https://www.terraform.io/docs/providers/aws/r/key_pair.html
resource "aws_key_pair" "ec2_key" {
  key_name = "${var.KEY_PAIR_NAME}"
  public_key = "${file("${var.PUBLIC_KEY_PATH}")}"
}

resource "aws_instance" "ProxyNode" {
  count         = "${var.AWS_INSTANCES_COUNT}"
  ami           = "${var.AWS_INSTANCE_AMI}"
  instance_type = "${var.AWS_INSTANCE_TYPE}"
  key_name      = "${aws_key_pair.ec2_key.key_name}"

  vpc_security_group_ids = ["${aws_security_group.ec2_proxies_sg.id}"]
  tags = {
    Name = "Proxy Node ${count.index}"
  }

  provisioner "file" {
    source      = "setup.sh"
    destination = "/home/${var.AWS_INSTANCE_USER_NAME}/setup.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x ./setup.sh",
      "sudo ./setup.sh ${var.AWS_INSTANCE_USER_NAME} ${var.PROXY_TYPE} ${var.PROXY_PORT} ${var.PROXY_USER} ${var.PROXY_PASSWORD}",
    ]
  }

  connection {
    type = "ssh"
    host = self.public_ip
    user = "${var.AWS_INSTANCE_USER_NAME}"
    private_key = "${file("${var.PRIVATE_KEY_PATH}")}"
  }
}

output "instances" {
  value = "${aws_instance.ProxyNode.*.public_ip}"
}
