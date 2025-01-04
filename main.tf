resource "aws_instance" "pratik-ec2-block" {
   ami = "ami-021e165d8c4ff761d"
   instance_type = "t2.micro"
   key_name = "psTerraform-key"
   vpc_security_group_ids = ["sg-039e937b06ba17320"]
   tags = {
      Name = "Pratik-ec2-os"
   }

}

resource "null_resource" "configuration_block" {

      connection {
         type = "ssh"
         user = "ec2-user"
         private_key = file("F:/psTerraform-key.pem")
         host = aws_instance.pratik-ec2-block.public_ip
      }
      provisioner "remote-exec" {
         inline = [
            "sudo yum install httpd -y",
            "sudo touch /var/www/html/index.html",
            "echo 'hi' | sudo tee /var/www/html/index.html",
            "sudo systemctl enable httpd --now"
          ]
      }

      depends_on = [
         aws_instance.pratik-ec2-block
      ]
}
