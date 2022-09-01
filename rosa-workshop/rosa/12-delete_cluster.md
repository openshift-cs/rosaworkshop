## Deleting a ROSA Cluster

To delete a ROSA cluster follow the steps below.

1. If you need to list your clusters in order to make sure you are deleting the correct one run:

		rosa list clusters

1. Once you know which one to delete run:

		rosa delete cluster --cluster <cluster-name>

	!!! danger
			**THIS IS NON-RECOVERABLE.**

1. It will prompt you to confirm that you want to delete it. Press “y”, then enter. The cluster and all its associated infrastructure will be deleted.

	!!! note
			All AWS STS/IAM roles and policies will remain and must be deleted manually once the cluster deletion is complete by following the steps below.

1. The command will output the next two commands to delete the other resources that were created.  You must wait until the cluster has finished deleting (from the previous command). You can use `rosa list clusters` to do a quick status check.

1. Once complete, delete the:

	1. OpenID Connect (OIDC) provider that you created for Operator authentication. Run

			rosa delete oidc-provider -c <clusterID> --mode auto --yes

	1. Cluster-specific Operator IAM roles.  Run

			rosa delete operator-roles -c <clusterID> --mode auto --yes

		!!! note
				The above require the cluster id to be used and not the cluster name.

1. The remaining roles would be account-scoped and should only be removed if they are <u>no longer needed by other clusters in the same account</u>. In other words, if you would still like to create other ROSA clusters in this account, do not perform this step.

	To delete these, you need to know the prefix used when creating them.  The default is "ManagedOpenShift" unless you specified otherwise.

		rosa delete account-roles --prefix <prefix> --mode auto --yes


*[ROSA]: Red Hat OpenShift Service on AWS
*[IdP]: Identity Provider
*[OCM]: OpenShift Cluster Manager
*[STS]: AWS Security Token Service
