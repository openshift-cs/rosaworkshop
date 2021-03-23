## Deploy the cluster
Use the `rosa` CLI to create the ROSA cluster.  

>**Note:** If you want to see all available options for your cluster run `rosa create cluster --help` or for interactive mode you can run `rosa create cluster --interactive`

1. Run the following command to create a cluster with all the default options 

    `rosa create cluster --cluster-name=<cluster name>`

    For example: 

    `rosa create cluster --cluster-name=my-rosa-cluster`

    You should see a response like the following:

    
        I: Creating cluster 'my-rosa-cluster'
        I: To view a list of clusters and their status, run 'rosa list clusters'
        I: Cluster 'my-rosa-cluster' has been created.
        I: Once the cluster is installed you will need to add an Identity Provider before you can login into the cluster. See 'rosa create idp --help' for more information.
        I: To determine when your cluster is Ready, run 'rosa describe cluster -c my-rosa-cluster'.
        I: To watch your cluster installation logs, run 'rosa logs install -c my-rosa-cluster --watch'.
        Name:                       my-rosa-cluster
        DNS:                        my-rosa-cluster.abcd.p1.openshiftapps.com
        ID:                         1idb8u7qc0jinctmmf0000000000000
        External ID:                
        AWS Account:                000000000000
        API URL:                    
        Console URL:                
        Nodes:                      Master: 3, Infra: 2, Compute: 2
        Region:                     us-east-1
        State:                      pending (Preparing account)
        Channel Group:              stable
        Private:                    No
        Created:                    Jan 24 2021 05:15:37 UTC
        Details Page:               https://cloud.redhat.com/openshift/details/1idb8u7qc0jinctmmf0000000000000
    
    This will take about 30-40 minutes to run.

    The default settings are as follows:

    * 3 Master Nodes, 2 Infra Nodes, 2 Worker Nodes
    * Worker node type: m5.xlarge
    * Region: As configured for the AWS CLI
    * The most recent version of OpenShift available to `rosa`
    * A single availability zone
    * Public cluster (Public API)

1. You can run the following command to check the status of the cluster

    `rosa describe cluster my-rosa-cluster`

    You should notice the state change from “pending” to “installing”.
    
1. Once the state has changed to “ready” your cluster is now installed.  
1. Run `rosa list clusters` to see a list of all available clusters.  You should see the one just created.

In the next step we will create an admin user to be able to use the cluster immediately.

*[ROSA]: Red Hat OpenShift Service on AWS