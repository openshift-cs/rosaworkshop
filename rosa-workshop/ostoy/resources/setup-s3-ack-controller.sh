#!/bin/bash

######################
# In short this script:
#   1. creates an AWS IAM Role with permissions to the AWS service
#   2. associates the AWS IAM role with the service account
#
# In more detail:
#   1. Creates a configmap to configure the operator, which is expected by the operator
#   2. Creates an AWS IAM role with trust policy for the serviceAccount created
#   3. Attaches the relevant policy to the IAM role as per the service
#   4. Gets the IRSA_ROLE_ARN and associates that with the service account
######################

######################
# Define variables for use in the script
######################
SERVICE="s3"                                                 # Update the service name variable as needed
AWS_REGION="us-west-2"                                       # Update the region if needed. Since S3 is global this has no impact.
ACK_K8S_NAMESPACE="ack-system"                               # This should not be changed
ACK_K8S_SERVICE_ACCOUNT_NAME="ack-${SERVICE}-controller"     # This should not be changed
ACK_CONTROLLER_IAM_ROLE="ack-${SERVICE}-controller"          # This may be renamed if you are running multiple clusters in the same AWS account
ACK_CONTROLLER_IAM_ROLE_DESCRIPTION="IRSA role for ACK ${SERVICE} controller deployment" # This may be modified

# Logic to set the OIDC_PROVIDER since it would differ if the cluster is ROSA HCP
# Confirm that the operator was already installed on the cluster

echo -n "Confirming that the ack-${SERVICE}-controller operator is present..."

# TODO: THIS WILL ONLY CHECK IF THE OPERATOR IS SUBSCRIBED TO BUT THE PODS IT MAY NOT BE PRESENT ON THE CLUSTER
if oc get subscriptions.operators.coreos.com -n $ACK_K8S_NAMESPACE 2>/dev/null | awk '{print $1}' | grep -q "ack-${SERVICE}-controller"; 
then 
  OIDC_PROVIDER=$(rosa describe cluster -c $(oc get clusterversion -o jsonpath='{.items[].spec.clusterID}{"\n"}') -o yaml | awk '/oidc_endpoint_url/ {print $2}' | cut -d '/' -f 3,4)
  echo "ok."
else
  echo "failed."
  echo "ack-${SERVICE}-controller was not found in ${ACK_K8S_NAMESPACE} namespace. Please ensure that you are logged into the correct cluster or that the operator was deployed."
  exit 1
fi

AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query "Account" --output text)
BASE_URL="https://raw.githubusercontent.com/aws-controllers-k8s/${SERVICE}-controller/main"
POLICY_ARN_URL="${BASE_URL}/config/iam/recommended-policy-arn"
POLICY_ARN_STRINGS="$(wget -qO- ${POLICY_ARN_URL})"
INLINE_POLICY_URL="${BASE_URL}/config/iam/recommended-inline-policy"
INLINE_POLICY="$(wget -qO- ${INLINE_POLICY_URL})"

# Check if the AWS role already existins in the AWS account
# If it does, then stop the script since the trust relationship may be different for this run that what is already there.
if aws iam get-role --role-name ${ACK_CONTROLLER_IAM_ROLE} > /dev/null 2>&1; then
cat << EOF
Error...${ACK_CONTROLLER_IAM_ROLE} role already exists.
Please delete the ${ACK_CONTROLLER_IAM_ROLE} role from AWS as the trust relationship may have changed
and this may be referring to an old role.

You may use the following commands to do so:
aws iam detach-role-policy --role-name ${ACK_CONTROLLER_IAM_ROLE} --policy-arn ${POLICY_ARN_STRINGS}
aws iam delete-role --role-name ${ACK_CONTROLLER_IAM_ROLE}
EOF

exit 1
fi

# create a configmap to configure the operator. Leave ACK_WATCH_NAMESPACE blank so the controller
# can properly watch all namespaces, and change any other values to suit your needs
cat <<EOF > config.txt
  ACK_ENABLE_DEVELOPMENT_LOGGING=true
  ACK_LOG_LEVEL=debug
  ACK_WATCH_NAMESPACE=
  AWS_REGION=${AWS_REGION}
  AWS_ENDPOINT_URL=
  ACK_RESOURCE_TAGS=rosa_cluster_ack
EOF

# If you change the name of the ConfigMap from the values given which is, "ack-$SERVICE-user-config",
# then installations from OperatorHub will not function properly. The Deployment for the controller is preconfigured for this key value.
oc create configmap --namespace ${ACK_K8S_NAMESPACE} --from-env-file=config.txt ack-${SERVICE}-user-config > /dev/null 2>&1
echo "\"ack-${SERVICE}-user-config\" ConfigMap created."

# create the trust policy file for the AWS IAM ROLE that will be created for the Operator
cat <<EOF > trust.json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Federated": "arn:aws:iam::${AWS_ACCOUNT_ID}:oidc-provider/${OIDC_PROVIDER}"
      },
      "Action": "sts:AssumeRoleWithWebIdentity",
      "Condition": {
        "StringEquals": {
          "${OIDC_PROVIDER}:sub": "system:serviceaccount:${ACK_K8S_NAMESPACE}:${ACK_K8S_SERVICE_ACCOUNT_NAME}"
        }
      }
    }
  ]
}
EOF

# create the AWS IAM Role
aws iam create-role --role-name "${ACK_CONTROLLER_IAM_ROLE}" --assume-role-policy-document file://trust.json --description "${ACK_CONTROLLER_IAM_ROLE_DESCRIPTION}" > /dev/null 2>&1
echo "IAM role ${ACK_CONTROLLER_IAM_ROLE} created."

# Attach IAM policy to the newly created IRSA IAM role
echo "Attaching IAM policy to ${ACK_CONTROLLER_IAM_ROLE}."

while IFS= read -r POLICY_ARN; do
    echo -n "Attaching $POLICY_ARN ... "
    aws iam attach-role-policy \
        --role-name "${ACK_CONTROLLER_IAM_ROLE}" \
        --policy-arn "${POLICY_ARN}"
    echo "ok."
done <<< "$POLICY_ARN_STRINGS"

if [ ! -z "$INLINE_POLICY" ]; then
    echo -n "Putting inline policy ... "
    aws iam put-role-policy \
        --role-name "${ACK_CONTROLLER_IAM_ROLE}" \
        --policy-name "ack-recommended-policy" \
        --policy-document "$INLINE_POLICY"
    echo "ok."
fi

# Generate the IRSA_ROLE_ARN for associating the service account
ACK_CONTROLLER_IAM_ROLE_ARN=$(aws iam get-role --role-name=$ACK_CONTROLLER_IAM_ROLE --query Role.Arn --output text)
IRSA_ROLE_ARN="eks.amazonaws.com/role-arn=${ACK_CONTROLLER_IAM_ROLE_ARN}"

# Annotate the K8s service account with the ARN for the IAM role
oc annotate serviceaccount --overwrite -n $ACK_K8S_NAMESPACE $ACK_K8S_SERVICE_ACCOUNT_NAME $IRSA_ROLE_ARN > /dev/null 2>&1
echo "Annotated service account."
echo "Operator deployment restarting..."

IRSA_ENVVAR=$(oc describe pod ack-$SERVICE-controller -n $ACK_K8S_NAMESPACE | grep "^\s*AWS_WEB_IDENTITY_TOKEN")
while [ -z "$IRSA_ENVVAR" ] ; do
        echo "...Not ready yet"
        oc rollout restart deployment ack-$SERVICE-controller -n $ACK_K8S_NAMESPACE > /dev/null 2>&1
        sleep 10
        IRSA_ENVVAR=$(oc describe pod ack-$SERVICE-controller -n $ACK_K8S_NAMESPACE | grep "^\s*AWS_WEB_IDENTITY_TOKEN")
    done
echo "Complete."
