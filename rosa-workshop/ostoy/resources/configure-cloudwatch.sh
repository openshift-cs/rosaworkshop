#!/bin/bash

#########################################
# This script is adapted from the Managed OpenShift Black Belts
# https://mobb.ninja/docs/rosa/clf-cloudwatch-sts/
# 
# The script configures the cluster to be used with AWS CloudWatch for Logging
#########################################


POLICY_ARN=$(aws iam list-policies --query "Policies[?PolicyName=='RosaCloudWatch'].{ARN:Arn}" --output text)
OIDC_ENDPOINT=$(rosa describe cluster -c $(oc get clusterversion -o jsonpath='{.items[].spec.clusterID}{"\n"}') -o yaml | awk '/oidc_endpoint_url/ {print $2}' | cut -d '/' -f 3,4)
AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)

if [ -z "$OIDC_ENDPOINT" ] && [ -z "$AWS_ACCOUNT_ID" ]; then
    echo "All variables are null."
elif [ -z "$OIDC_ENDPOINT" ]; then
    echo "OIDC_ENDPOINT is null."
    exit 1
elif [ -z "$AWS_ACCOUNT_ID" ]; then
    echo "AWS_ACCOUNT_ID is null."
    exit 1
else
    echo "Varaibles are set...ok."
fi

# Create an IAM Policy for OpenShift Log Forwarding if it doesnt already exist
if [[ -z "${POLICY_ARN}" ]]; then
cat << EOF > ${HOME}/cw-policy.json
{
"Version": "2012-10-17",
"Statement": [
   {
         "Effect": "Allow",
         "Action": [
            "logs:CreateLogGroup",
            "logs:CreateLogStream",
            "logs:DescribeLogGroups",
            "logs:DescribeLogStreams",
            "logs:PutLogEvents",
            "logs:PutRetentionPolicy"
         ],
         "Resource": "arn:aws:logs:*:*:*"
   }
]
}
EOF
POLICY_ARN=$(aws iam create-policy --policy-name "RosaCloudWatch" --policy-document file:///${HOME}/cw-policy.json --query Policy.Arn --output text)
fi

# Create an IAM Role trust policy for the cluster
cat <<EOF > ${HOME}/cloudwatch-trust-policy.json
{
  "Version": "2012-10-17",
  "Statement": [{
    "Effect": "Allow",
    "Principal": {
    "Federated": "arn:aws:iam::${AWS_ACCOUNT_ID}:oidc-provider/${OIDC_ENDPOINT}"
    },
    "Action": "sts:AssumeRoleWithWebIdentity",
    "Condition": {
      "StringEquals": {
        "${OIDC_ENDPOINT}:sub": "system:serviceaccount:openshift-logging:logcollector"
      }
    }
  }]
}
EOF

# Create the role
export ROLE_ARN=$(aws iam create-role --role-name "RosaCloudWatch-${GUID}" \
--assume-role-policy-document file://${HOME}/cloudwatch-trust-policy.json \
--tags "Key=rosa-workshop,Value=true" \
--query Role.Arn --output text)

# Attach the IAM Policy to the IAM Role
aws iam attach-role-policy --role-name "RosaCloudWatch-${GUID}" --policy-arn "${POLICY_ARN}"

# Deploy the Cluster Logging operator
cat << EOF | oc apply -f -
apiVersion: operators.coreos.com/v1alpha1
kind: Subscription
metadata:
  labels:
   operators.coreos.com/cluster-logging.openshift-logging: ""
  name: cluster-logging
  namespace: openshift-logging
spec:
  channel: stable
  installPlanApproval: Automatic
  name: cluster-logging
  source: redhat-operators
  sourceNamespace: openshift-marketplace
EOF

echo "Waiting for cluster logging operator deployment to complete..."

sleep 15

# wait for the OpenShift Cluster Logging Operator to install
while ! oc -n openshift-logging rollout status deployment cluster-logging-operator 2>/dev/null | grep -q "successfully"; do
    echo "Waiting for cluster logging operator deployment to complete..."
    sleep 10
done

echo "Cluster logging operator deployed."

# create a secret containing the ARN of the IAM role that we previously created above.
cat << EOF | oc apply -f -
apiVersion: v1
kind: Secret
metadata:
  name: cloudwatch-credentials
  namespace: openshift-logging
stringData:
  role_arn: ${ROLE_ARN}
EOF

# configure the OpenShift Cluster Logging Operator by creating a Cluster Log Forwarding custom resource that will forward logs to AWS CloudWatch
cat << EOF | oc apply -f -
apiVersion: logging.openshift.io/v1
kind: ClusterLogForwarder
metadata:
  name: instance
  namespace: openshift-logging
spec:
  outputs:
  - name: cw
    type: cloudwatch
    cloudwatch:
      groupBy: namespaceName
      groupPrefix: rosa-${GUID}
      region: us-east-2
    secret:
      name: cloudwatch-credentials
  pipelines:
  - name: to-cloudwatch
    inputRefs:
    - infrastructure
    - audit
    - application
    outputRefs:
    - cw
EOF

#  create a Cluster Logging custom resource which will enable the OpenShift Cluster Logging Operator to start collecting logs
cat << EOF | oc apply -f -
apiVersion: logging.openshift.io/v1
kind: ClusterLogging
metadata:
  name: instance
  namespace: openshift-logging
spec:
  collection:
    logs:
      type: fluentd
  forwarder:
    fluentd: {}
  managementState: Managed
EOF

echo "Complete."