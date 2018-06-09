provider "aws" {
  access_key = "${var.AWS_ACCESS_KEY_ID}"
  secret_key = "${var.AWS_SECRET_ACCESS_KEY}"
  region = "${var.AWS_DEFAULT_REGION}"
}

resource "aws_security_group" "ec2_proxies_sg" {
  name = "ec2_proxies_sg"

  // Open up incoming ssh port
  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  // Open up outbound internet access
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  // Open up incoming traffic for proxy
  ingress {
    from_port   = "${var.PROXY_PORT}"
    to_port     = "${var.PROXY_PORT}"
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "ProxyNode" {
  count         = "${var.AWS_INSTANCES_COUNT}"
  ami           = "${var.AWS_INSTANCE_AMI}"
  instance_type = "${var.AWS_INSTANCE_TYPE}"
  key_name      = "${var.KEY_PAIR_NAME}"
  vpc_security_group_ids = ["${aws_security_group.ec2_proxies_sg.id}"]
  tags {
    Name = "Proxy Node ${count.index}"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo apt update",
      "curl -L https://raw.githubusercontent.com/snail007/goproxy/master/install_auto.sh | sudo bash",
      "proxy ${var.PROXY_TYPE} -t tcp -p '0.0.0.0:${var.PROXY_PORT}' --daemon",
    ]

    connection {
      type = "ssh"
      user = "${var.AWS_INSTANCE_USER_NAME}"
      private_key = "${file(var.PRIVATE_KEY_PATH)}"
    }
  }
}

output "node_dns_name" {
  value = "${aws_instance.ProxyNode.public_dns}"
}
