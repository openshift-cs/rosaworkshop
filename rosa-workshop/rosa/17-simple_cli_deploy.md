This page is a super easy to follow, "TL;DR", minimum list of commands to get a ROSA cluster deployed using the CLI. This will work great for this workshop, though more attention should be paid for clusters to be used in production.

## Assumptions

The steps on this page assume you have completed the prerequisites in the [Setup](/rosa/1-account_setup) section.

## Create account roles
Run <u>once</u> per AWS account, per y-stream OpenShift version:

```
rosa create account-roles --mode auto --yes
```

## Deploy the cluster

1. Create the cluster with the [default configuration](/rosa/2-deploy/#default-configuration).  Just choose a cluster name.
        
    ```
    rosa create cluster --cluster-name <cluster-name> --sts --mode auto --yes
    ```

1. Check the status.

    ```
    rosa list clusters
    ```


*[ROSA]: Red Hat OpenShift Service on AWS
*[STS]: AWS Security Token Service
*[OCM]: OpenShift Cluster Manager
