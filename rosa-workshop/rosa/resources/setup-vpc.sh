#!/bin/bash

set -e
##########
# This script will create the network requirements for a ROSA cluster.  This will be
# a public cluster.  This creates:
# - VPC
# - Public and private subnets
# - Internet Gateway
# - Relevant route tables
# - NAT Gateway
#
# This will automatically use the region configured for the aws cli
#
##########

VPC_CIDR=10.0.0.0/16
PUBLIC_CIDR_SUBNET=10.0.1.0/24
PRIVATE_CIDR_SUBNET=10.0.0.0/24

# Create VPC
echo -n "Creating VPC..."
VPC_ID=$(aws ec2 create-vpc --cidr-block $VPC_CIDR --query Vpc.VpcId --output text)

# Create tag name
aws ec2 create-tags --resources $VPC_ID --tags Key=Name,Value=$CLUSTER_NAME

# Enable dns hostname
aws ec2 modify-vpc-attribute --vpc-id $VPC_ID --enable-dns-hostnames
echo "done."

# Create Public Subnet
echo -n "Creating public subnet..."
PUBLIC_SUBNET_ID=$(aws ec2 create-subnet --vpc-id $VPC_ID --cidr-block $PUBLIC_CIDR_SUBNET --query Subnet.SubnetId --output text)

aws ec2 create-tags --resources $PUBLIC_SUBNET_ID --tags Key=Name,Value=$CLUSTER_NAME-public
echo "done."

# Create private subnet
echo -n "Creating private subnet..."
PRIVATE_SUBNET_ID=$(aws ec2 create-subnet --vpc-id $VPC_ID --cidr-block $PRIVATE_CIDR_SUBNET --query Subnet.SubnetId --output text)

aws ec2 create-tags --resources $PRIVATE_SUBNET_ID --tags Key=Name,Value=$CLUSTER_NAME-private
echo "done."

# Create an internet gateway for outbound traffic and attach it to the VPC.
echo -n "Creating internet gateway..."
IGW_ID=$(aws ec2 create-internet-gateway --query InternetGateway.InternetGatewayId --output text)
echo "done."

aws ec2 create-tags --resources $IGW_ID --tags Key=Name,Value=$CLUSTER_NAME

aws ec2 attach-internet-gateway --vpc-id $VPC_ID --internet-gateway-id $IGW_ID > /dev/null 2>&1
echo "Attached IGW to VPC."

# Create a route table for outbound traffic and associate it to the public subnet.
echo -n "Creating route table for public subnet..."
PUBLIC_ROUTE_TABLE_ID=$(aws ec2 create-route-table --vpc-id $VPC_ID --query RouteTable.RouteTableId --output text)

aws ec2 create-tags --resources $PUBLIC_ROUTE_TABLE_ID --tags Key=Name,Value=$CLUSTER_NAME
echo "done."

aws ec2 create-route --route-table-id $PUBLIC_ROUTE_TABLE_ID --destination-cidr-block 0.0.0.0/0 --gateway-id $IGW_ID > /dev/null 2>&1
echo "Created default public route."

aws ec2 associate-route-table --subnet-id $PUBLIC_SUBNET_ID --route-table-id $PUBLIC_ROUTE_TABLE_ID > /dev/null 2>&1
echo "Public route table associated"

# Create a NAT gateway in the public subnet for outgoing traffic from the private network.
echo -n "Creating NAT Gateway..."
NAT_IP_ADDRESS=$(aws ec2 allocate-address --domain vpc --query AllocationId --output text)

NAT_GATEWAY_ID=$(aws ec2 create-nat-gateway --subnet-id $PUBLIC_SUBNET_ID --allocation-id $NAT_IP_ADDRESS --query NatGateway.NatGatewayId --output text)

aws ec2 create-tags --resources $NAT_IP_ADDRESS --resources $NAT_GATEWAY_ID --tags Key=Name,Value=$CLUSTER_NAME
sleep 10
echo "done."

# Create a route table for the private subnet to the NAT gateway.
echo -n "Creating a route table for the private subnet to the NAT gateway..."
PRIVATE_ROUTE_TABLE_ID=$(aws ec2 create-route-table --vpc-id $VPC_ID --query RouteTable.RouteTableId --output text)

aws ec2 create-tags --resources $PRIVATE_ROUTE_TABLE_ID $NAT_IP_ADDRESS --tags Key=Name,Value=$CLUSTER_NAME-private
 
aws ec2 create-route --route-table-id $PRIVATE_ROUTE_TABLE_ID --destination-cidr-block 0.0.0.0/0 --gateway-id $NAT_GATEWAY_ID > /dev/null 2>&1

aws ec2 associate-route-table --subnet-id $PRIVATE_SUBNET_ID --route-table-id $PRIVATE_ROUTE_TABLE_ID > /dev/null 2>&1

echo "done."

# echo "***********VARIABLE VALUES*********"
# echo "VPC_ID="$VPC_ID
# echo "PUBLIC_SUBNET_ID="$PUBLIC_SUBNET_ID
# echo "PRIVATE_SUBNET_ID="$PRIVATE_SUBNET_ID
# echo "PUBLIC_ROUTE_TABLE_ID="$PUBLIC_ROUTE_TABLE_ID
# echo "PRIVATE_ROUTE_TABLE_ID="$PRIVATE_ROUTE_TABLE_ID
# echo "NAT_GATEWAY_ID="$NAT_GATEWAY_ID
# echo "IGW_ID="$IGW_ID
# echo "NAT_IP_ADDRESS="$NAT_IP_ADDRESS

echo "Setup complete."
echo ""
echo "To make the cluster create commands easier, please run the following commands to set the environment variables:"
echo "export PUBLIC_SUBNET_ID=$PUBLIC_SUBNET_ID"
echo "export PRIVATE_SUBNET_ID=$PRIVATE_SUBNET_ID"
