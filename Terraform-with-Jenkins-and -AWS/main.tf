


#Calls to our imported VPC for use
resource "aws_default_vpc" "snowy_vpc" {
  tags = {
    Name = "Default VPC"
  }
}
#Creates our EC2 instance
resource "aws_instance" "jenkins_ec2" {
  ami           = var.image_id
  instance_type = "t2.micro"
  vpc_security_group_ids = var.security_group
}
  #Creates our local-exec provisioner that will change permissions of my private key to connect to the virtual machine.
  provisioner "local-exec" {
    command = "chmod 600 ${local_file.private_key_pem.filename}"
  }

  #Creates the remote-exec provisioner to execute commands on the remote resource after creation
  provisioner "remote-exec" {
    inline = [
        "sudo yum update -y",
      "sudo wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo",
      "sudo rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io-2023.key",
      "sudo yum upgrade",
      "sudo amazon-linux-extras install java-openjdk11 -y",
      "sudo dnf install java-11-amazon-corretto -y",
      "sudo yum install jenkins -y",
      "sudo systemctl enable jenkins",
      "sudo systemctl start jenkins",
      "sudo systemctl status jenkins"
    ]
  }
  associate_public_ip_address = true
  key_name                    = aws_key_pair.generated.key_name #references my key pair 
  connection {                                                  #the connection block specifies the user name, ip, and authentication scheme to connect to the server. Must be embedded in the resource block.
    user        = "ec2-user"
    private_key = tls_private_key.generated.private_key_pem
    host        = self.public_ip
  }
  tags = {
    Name = "ThisEC2IsForJenkins"
  }
# This utilizes the TLS provider to generate an SSH key
resource "tls_private_key" "generated" {
  algorithm = "RSA"
}

# This uses terraform local provider in terraform.tf to save the TLS key to a file called "MyAWSKey.pem" in my local file system.
resource "local_file" "private_key_pem" {
  content  = tls_private_key.generated.private_key_pem
  filename = "MyAWSKey.pem"
}

#Generates a key pair in AWS using the previous TLS key file 
resource "aws_key_pair" "generated" {
  key_name   = "MyAWSKey"
  public_key = tls_private_key.generated.public_key_openssh

  lifecycle {
    ignore_changes = [key_name]
  }
}

# Creates security group that allows web traffic over the HTTP port & ssh traffic on port 22
resource "aws_security_group" "vpc_web_ssh" {
  name        = "allow-ssh-web"
  vpc_id      = aws_default_vpc.snowy_vpc.id
  description = "SSH & 8080 Web Traffic"
  ingress {
    description = "Allow Port 8080"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
   ingress {
    cidr_blocks = [
      "0.0.0.0/0"
    ]
    from_port = 22
    to_port   = 22
    protocol  = "tcp"
  }
  egress {
    description = "Allow all ip and ports outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    }
}

resource "aws_s3_bucket" "jenkins_artifacts_s3" {
  bucket = "week20-s3bucket-dparria" # Set a unique bucket name
}

resource "aws_s3_bucket_ownership_controls" "s3_ownership" {
  bucket = aws_s3_bucket.jenkins_artifacts_s3.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_acl" "jenkins_s3_acl" {
    depends_on = [aws_s3_bucket_ownership_controls.s3_ownership]

  bucket = aws_s3_bucket.jenkins_artifacts_s3.id
  acl    = "private"
}