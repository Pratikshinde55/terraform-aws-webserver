
data "aws_ami" "ami-id-ec2" {
     most_recent = true
     owners = ["amazon"]

     filter {
       name = "name"
       values = ["al2023-ami-*-x86_64"]
     }
     filter {
       name = "root-device-type"
       values = ["ebs"]
     }
     filter {
       name = "virtualization-type"
       values = ["hvm"]
     }
}

resource "aws_instance" "pratik-ec2-resource" {

    #count = length(aws_subnet.ps-subnet)                                     #This will launch one EC2 instance in each subnet for multiple ec2 by using count =5.
    ami = data.aws_ami.ami-id-ec2.id
    instance_type = var.InstanceType
    key_name = "psTerraform-key"
    vpc_security_group_ids = [aws_security_group.Pratik-SG-block.id]  
    subnet_id = element(aws_subnet.ps-subnet.*.id, 0)                                      ## Subnet referance give with elemnt because there is two subnet i created for single VPC.
    associate_public_ip_address = true                                                     ## public IP is assigned
    tags = {
       Name = var.InstanceName
    }

    depends_on = [
       aws_vpc.Pratik-vpc-block,
       aws_subnet.ps-subnet,
       aws_security_group.Pratik-SG-block  # Ensure SG is created before the instance
    ]
}


variable "InstanceName" {
   type = string
   default = "Pratik-ec2-webserver"
}

variable "InstanceType" {
   type = string
   default = "t2.micro"
}



resource "aws_ec2_instance_state" "test" {
  instance_id = aws_instance.pratik-ec2-resource.id
  state       = "running"                              ## stopped, running
}

resource "null_resource" "PS-WEB-Block" {
  
    connection {
       type = "ssh"
       user = "ec2-user"
       private_key = file("F:/psTerraform-key.pem")
       host = aws_instance.pratik-ec2-resource.public_ip
    }
    provisioner "remote-exec" {
       inline = [
            "sudo yum install httpd -y",
            "sudo touch /var/www/html/index.html",
            "echo 'hi I am Pratik Shinde From HTTPD Apache wenserver' | sudo tee /var/www/html/index.html",
            "sudo systemctl enable httpd --now"
       ]
    } 
    depends_on = [
          aws_instance.pratik-ec2-resource
    ]
}
        


##############VPC##################

resource "aws_vpc" "Pratik-vpc-block" {
   cidr_block = var.VPC-CIDR
   tags = {
      Name = var.VPC-Name
   }
}


variable "VPC-Name" {
   type = string
   default = "Pratik-VPC"
}

variable "VPC-CIDR" {
   default = "10.0.0.0/16"
}


resource "aws_internet_gateway" "mygateway-block" {
   vpc_id = aws_vpc.Pratik-vpc-block.id
   tags = {
       Name = "Pratik-Internet-Gateway"
   }
}

############ AWS_subnet custom create with two subnet range 

resource "aws_subnet" "ps-subnet" {
   count = length(var.SubnetRange)                                     # Here i define count as lenght
   vpc_id = aws_vpc.Pratik-vpc-block.id
   cidr_block = element(var.SubnetRange , count.index)                 ## This element go to 1st var.subnetRange varibles and then increase as count.index, It means two times because two subnetRange i put.
   availability_zone = element(var.zoneRange , count.index)            ##element --> var.zone.range --> count.index , This done because i define "count".
   map_public_ip_on_launch = true
   tags = {
       Name = "Subnet-${count.index + 1}"
   }
   depends_on = [
         aws_vpc.Pratik-vpc-block,
   ]
}

variable "SubnetRange" {
    type = list(string)
    default = [ "10.0.1.0/24" , "10.0.2.0/24"]
}
variable "zoneRange" {
    type = list(string)
    default = ["ap-south-1a", "ap-south-1b"]
} 

########## create custom route table with own VPC #####################

resource "aws_route_table" "ps-route-block" {
     vpc_id = aws_vpc.Pratik-vpc-block.id
     
     route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.mygateway-block.id
     }
     tags = {
        Name = "Pratik-route-table"
     }
}

##################  Provides a resource to create an association between a route table and  a subnet or a route table and an internet gateway or virtual private gateway. ###############


resource "aws_route_table_association" "pratik-route-asso-block" {
      count = length(var.SubnetRange)                                           ## Here i dine count as lenght dynamic
      subnet_id = element(aws_subnet.ps-subnet.*.id , count.index)
      route_table_id = aws_route_table.ps-route-block.id
}


#################  AWS_Security_group assigned with own VPC #############################

resource "aws_security_group" "Pratik-SG-block" {
   name = "terraform-allow-ssh-ps${var.SG_NAME}"
   description = "Allow Inbound traffic for SSH and HTTTP for WEBSERVER"
   vpc_id = aws_vpc.Pratik-vpc-block.id
   
   dynamic "ingress" {
      for_each = var.SG-TCP-ALLOW 
      iterator = port
      content {
         description = "TCP from VPC to WEBSERVER"
         from_port = port.value
         to_port = port.value
         protocol = "tcp"
         cidr_blocks = ["0.0.0.0/0"]
      }
   }
   egress {
     from_port = 0
     to_port = 0
     protocol = "-1"
     cidr_blocks = ["0.0.0.0/0"]
   }
   depends_on = [
         aws_vpc.Pratik-vpc-block,
   ]

}

variable "SG-TCP-ALLOW" {
   type = list(number)
   default = [22, 80, 8080, 443]
}

variable "SG_NAME" {
    default = "Pratik-SG"
}

###################  Terraform Map type is use to store multiple values at single variable, In output we get all data in only one call ##################

variable "myMap" {
   type = map
   default = {
       AuthorName = "Pratik",
       mob = 985055,
       email = "pratikshinde@gmail.com",
       student_id = 112233
    }
}

output "Retrieve-info" {
    value = var.myMap
}

############ Terraform locals helps to use Terraform function, but can't insert values while calling from module block.##########################

locals {
   service_Name = "Pratik_Terraform"
   owner = "DevOps-ps"
   psmax = max(5055, 55, 77, 5555)
   CurrentTime =  formatdate("DD MMM YYYY hh : mm Z", timestamp())
}

output "lOCAL-out" {
   value = local.CurrentTime 
}

######### This variable helps to give button during apply terraform file for custom output #################

variable "Put-true-to-run" {
    type = bool
}

output "OutPutASK" {
    value = var.Put-true-to-run == true? "hey WlC from Pratik" : "Bye..! meet next type "
}
