# Create Webserver using Terraform for AWS provider

## info

**element()** :-  function to select one subnet from multiple subnets dynamically. 

**subnet_id = element(aws_subnet.ps-subnet.*.id, 0)**  -->  this place the EC2 instance in the first subnet (count.index = 0), if want place in second then use 1.

**count** --> for dynamically creating multiple subnets

