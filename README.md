# Create Webserver using Terraform for AWS provider

## info

**element()** :-  function to select one subnet from multiple subnets dynamically. 

**subnet_id = element(aws_subnet.ps-subnet.*.id, 0)**  -->  this place the EC2 instance in the first subnet (count.index = 0), if want place in second then use 1.

**count** --> for dynamically creating multiple subnets

## Code explain:

## Step-1: [ aws_ami Data Source]

**most_recent:**  Fetches the latest AMI.

**owners:** Filters defines use onlu amazon .

**filter:** Filters AMIs by name, root device type (ebs), and virtualization type (hvm), which are typical for most Amazon Linux images.

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


## Step-: [aws_instance Resource]
