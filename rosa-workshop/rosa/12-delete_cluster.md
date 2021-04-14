## Deleting a ROSA Cluster

To delete a ROSA cluster follow the steps below.

1. If you need to list your clusters in order to make sure you are deleting the correct one run

	`rosa list clusters`

2. Once you know which one to delete run

	`rosa delete cluster --cluster=<clustername>`

3. It will prompt you to confirm that you want to delete it. Press “y” then enter. The cluster will be deleted and all associated infrastructure. **THIS IS NON-RECOVERABLE.**
4. If you want to completely remove all associated aspects of the ROSA service (such as stack templates) you can run 

	`rosa init --delete-stack`


*[ROSA]: Red Hat OpenShift Service on AWS
*[IdP]: Identity Provider
*[OCM]: OpenShift Cluster Manager