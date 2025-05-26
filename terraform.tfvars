
# MONGO_URI = "mongodb+srv://user:1234@tasks.hqybvw0.mongodb.net/?retryWrites=true&w=majority&appName=tasks"
# UPDATE BELOW 3 TOGETHER using "ce-grp-4_vpc" tf
vpc_id = "vpc-0d9bfd8193a28db14"
 # Public subnets from VPC repo
alb_subnet_ids = [ "subnet-02cae5f5e714bc475", "subnet-04fc5bbaf6b95e6c0" ]
 # Private subnets from VPC repo
private_subnet_ids = ["subnet-079f012fb29ab9853", "subnet-070d03cd050d8378c"]