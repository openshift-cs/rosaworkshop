In this section we will deploy a ROSA cluster using Hosted Control Planes (HCP).  

In short, with ROSA HCP you can decouple the control plane from the data plane (workers).  This is a new deployment model for ROSA in which the control plane is hosted in a Red Hat owned AWS account.  Therefore the control plane is no longer hosted in your AWS account thus reducing your AWS infrastructure expenses. The control plane is dedicated to a single cluster and is highly available. See the documentation for more about [Hosted Control Planes](https://docs.openshift.com/rosa/rosa_hcp/rosa-hcp-sts-creating-a-cluster-quickly.html).

!!! important
    As of this writing Hosted Control Planes (HCP) is currently a Technology Preview feature only. Technology Preview features are not supported with Red Hat production service level agreements (SLAs) and might not be functionally complete. 

## Prerequisites

ROSA HCP requires two things to be created before deploying the cluster:

1. VPC - This is a "BYO VPC" model
1. OIDC configuration

Let's create those first.

### VPC
1. Before creating your VPC ensure that your `aws` cli is configured to use a region where ROSA w/HCP is available.  To find out which regions are supported run:

    ```
    rosa list regions --hosted-cp
    ```
    
1. Create the VPC. For this workshop, there is a script provided that will create the VPC and its required components for you. It will use the region configured for the `aws` cli.

    Please feel free to read it first, or live on the edge and just run it.

    ```
    curl https://raw.githubusercontent.com/openshift-cs/rosaworkshop/master/rosa-workshop/rosa/resources/setup-vpc.sh | bash
    ```

    See the [documentation](https://docs.openshift.com/rosa/rosa_planning/rosa-sts-aws-prereqs.html#rosa-vpc_rosa-sts-aws-prereqs) for more about VPC requirements.

1. There are two commands that are outputted from the script. Set those as environment variables to make running the create cluster command easier. Copy them from the output and run them.

    ```
    export PUBLIC_SUBNET_ID=<public subnet id here>
    export PRIVATE_SUBNET_ID=<private subnet id here>
    ```

### OIDC Configuration

To create the OIDC configuration to be used in this workshop, run the following command.  We are opting for the automatic mode as this is simpler for the workshop purposes as well as for it to be Red Hat managed. We are also going to store the OIDC ID to an environment variable for later use.

```
export OIDC_ID=$(rosa create oidc-config --mode auto --managed --yes -o json | jq -r '.id')
```

### Helper environment variables

Let's set up some environment variables so that it will be easier to run the command for creating the ROSA HCP cluster.

```
export CLUSTER_NAME=<enter cluster name>
export REGION=<region VPC was created in>
```

## Create the cluster
If this is the <u>first time</u> you are deploying ROSA in this account and have <u>not yet created the account roles</u>, then create the account-wide roles and policies, including Operator policies.

1. Run the following command to create the account-wide roles:

    ```
    rosa create account-roles --mode auto --yes
    ```

1. Run the following command to create the cluster:

    ```
    rosa create cluster --cluster-name $CLUSTER_NAME \
        --subnet-ids ${PUBLIC_SUBNET_ID},${PRIVATE_SUBNET_ID} \
        --hosted-cp \
        --region $REGION \
        --oidc-config-id $OIDC_ID \
        --sts --mode auto --yes
    ```

    In about 10 minutes the control plane and API will be up, and about 5-10 minutes after, the worker nodes will be up and the cluster will be completely usable.  

## Check installation status
1. You can run the following command to check the detailed status of the cluster:

    ```
    rosa describe cluster --cluster $CLUSTER_NAME
    ```

    or you can run the following for an abridged view of the status:

    ```
    rosa list clusters
    ```

    Lastly, you can also watch the logs as it progresses:

    ```
    rosa logs install --cluster $CLUSTER_NAME --watch
    ```

1. Once the state changes to “ready” your cluster is now installed. It may take a few more minutes for the worker nodes to come online.