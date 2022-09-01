## Autoscaling

Autoscaling can refer to two things.  Either:

- [Horizontal Pod Autoscaler](https://docs.openshift.com/container-platform/latest/nodes/pods/nodes-pods-autoscaling.html) - whereby Kubernetes will automatically create more or remove pods of an application to handle an increase/decrease in workload, though total resources available to the cluster will remain unchanged.
- [Cluster Autoscaler](https://docs.openshift.com/rosa/rosa_cluster_admin/rosa_nodes/rosa-nodes-about-autoscaling-nodes.html) - This is where more worker nodes will be added or removed from the cluster based on pods failing due to insufficient resources thereby affecting the total number of resources available.

We will focus on the second as it relates to ROSA.

!!! note
    Cluster autoscaling can also be enabled at cluster creation time using the `--enable-autoscaling` flag. This will enable autoscaling on the "Default" machine pool. It can also be enabled when creating a machine pool.

#### Setting up cluster autoscaling
1. Autoscaling is set per machine pool definition. To find out which machine pools are available in our cluster run

        rosa list machinepools -c <cluster-name>

    You will see a response like:

        ID         AUTOSCALING  REPLICAS  INSTANCE TYPE  LABELS     TAINTS    AVAILABILITY ZONES
        Default    No           2         m5.xlarge                           us-east-1a


1. Now run the following to add autoscaling to that machine pool.

        rosa edit machinepool -c <cluster-name> --enable-autoscaling <machinepool-name> --min-replicas=<num> --max-replicas=<num>

    For example:

        rosa edit machinepool -c my-rosa-cluster --enable-autoscaling Default --min-replicas=2 --max-replicas=4

    This will create an autoscaler for the worker nodes to scale between 2 and 4 nodes depending on the resources.

    The cluster autoscaler increases the size of the cluster when there are pods that failed to schedule on any of the current nodes due to insufficient resources or when another node is necessary to meet deployment needs. The cluster autoscaler does not increase the cluster resources beyond the limits that you specify. The cluster autoscaler decreases the size of the cluster when some nodes are consistently not needed for a significant period, such as when it has low resource use and all of its important pods can fit on other nodes.

1. This can also be done via the OCM UI. You might have noticed a checkbox at machine pool creation time for "Enable autoscaling"

1. Lastly autoscaling can also be added to an existing machine pool via the UI by going to the "Machine pools" tab in OCM for your cluster > clicking on the "three dots" at the right for the machine pool > "Scale" > "Enable autoscaling".

1. Run the following to confirm that autoscaling was added

        rosa list machinepools -c <cluster-name>

    You will see a response like:

        ID         AUTOSCALING  REPLICAS  INSTANCE TYPE  LABELS     TAINTS    AVAILABILITY ZONES
        Default    Yes          2-4       m5.xlarge                           us-east-1a



*[ROSA]: Red Hat OpenShift Service on AWS
*[IdP]: Identity Provider
*[OCM]: OpenShift Cluster Manager
