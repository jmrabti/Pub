#!/bin/bash

set -e

set -u

 

clear

 

ami="ami-05f37c3995fffb4fd"

size="t2.micro"

today=$(date +"%m-%d-%y-%H%M")

localip=$(curl -s https://ipinfo.io/ip)

region="us-east-1" #define your region


printf "Launching EC2 Instance...\\n"

printf "AMI: %s\\n" "$ami"

printf "Type: %s\\n" "$size"

printf "\\n"

 

# Create SSH Key

aws ec2 create-key-pair --key-name MyKey$today --query 'KeyMaterial' --output text >  ~/Documents/MyKey$today.pem

chmod 400  ~/Documents/MyKey"$today".pem

#!/bin/bash

set -e

set -u

 

clear

 

ami="ami-05f37c3995fffb4fd"

size="t2.micro"

today=$(date +"%m-%d-%y-%H%M")

localip=$(curl -s https://ipinfo.io/ip)



printf "Launching EC2 Instance...\\n"

printf "AMI: %s\\n" "$ami"

printf "Type: %s\\n" "$size"

printf "\\n"

 

# Create SSH Key

aws ec2 create-key-pair --key-name MyKey$today --query 'KeyMaterial' --output text >  ~/Documents/MyKey$today.pem

chmod 400  ~/Documents/MyKey"$today".pem


# Create Security Group

aws ec2 create-security-group --group-name SG-"$today" --description "Security Group OpenVPN" > /dev/null

aws ec2 authorize-security-group-ingress --group-name SG-"$today" --cidr "$localip"/32 --protocol tcp --port 1194


# Launch a Ec2 instance

instance=$(aws ec2 run-instances --image-id $ami --instance-type $size --key-name  MyKey"$today" --region $region --security-groups SG-"$today" --output text --user-data file://user_data.txt)

 
id=$(printf "$instance" | grep INSTANCES | cut -f 8)

state=$(printf "$

instance" | grep STATE | head -n 1 | cut -f 3)

printf "Instance launched: %s \\n" "$id"

printf "\\n"

 

# tag the instance

aws ec2 create-tags --resources $id --tags Key=Name,Value="OpenVPN"
 

printf "Starting Instance: \\n"


# Wait for instance in `running` status

while [ "$state" = pending ]; do

    echo -ne "Waiting for running status...\\r"

    sleep 10

    info=$(aws ec2 describe-instances --instance-ids $id --output text)

    state=$(echo "$info" | grep STATE | cut -f 3)

done

 

printf "\\n"

 

# Fetch the public host name

awsip=$(aws ec2 describe-instances --instance-ids $id --query "Reservations[*].Instances[*].PublicIpAddress" --output=text)



# Probe SSH connection until it's available

X_READY=''

while [ ! $X_READY ]; do

    echo -ne "Waiting for ready status...\\r"

    sleep 10

    set +e

    out=$(ssh -o ConnectTimeout=1 -o StrictHostKeyChecking=no -o BatchMode=yes ec2-user@$awsip 2>&1 | grep 'Permission denied' )

    [[ $? = 0 ]] && X_READY='ready'

    set -e

done

 

printf "\\n"

printf "\\n"


# Done

printf "EC2 instance is Ready!\\n"


printf "\\n"


sleep 60

# wait a minute while the user_data script install & configure OpenVPN and create user

printf "\\n"


# everything should be ready in the backend now, retrieve the config file 
# By default, OpenVPN will create a user and copy the config file to /root but this version it is in /home/ec2-user

ssh -i ~/Documents/MyKey$today.pem ec2-user@"$awsip" 'cat /home/ec2-user/user1.ovpn'


# Enjoy VPNing

 

