## Autoscaling

In this section we will explore how the [Horizontal Pod Autoscaler](https://kubernetes.io/docs/tasks/run-application/horizontal-pod-autoscale/) (HPA) can be used and works within Kubernetes/OpenShift. 

As defined in the Kubernetes documentation:
> Horizontal Pod Autoscaler automatically scales the number of pods in a replication controller, deployment, replica set or stateful set based on observed CPU utilization.

We will create an HPA and then use OSToy to generate CPU intensive workloads.  We will then observe how the HPA will scale up the number of pods in order to handle the increased workloads.  

### Create the Horizontal Pod Autoscaler

Run the following command to create the autoscaler. The following command will create an HPA that maintains between 1 and 10 replicas of the Pods controlled by the *ostoy-microservice* deployment we created. Roughly speaking, the HPA will increase and decrease the number of replicas (via the deployment) to maintain an average CPU utilization across all Pods of 80% (since each pod requests 50 millicores, this means average CPU usage of 40 millicores)

`oc autoscale dc/ostoy-microservice --cpu-percent=80 --min=1 --max=10`

### View the current number of pods

View the current number of pods via the menu item on the left for HPA.


### Increase the load

### View the pods scale up
