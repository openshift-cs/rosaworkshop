## Autoscaling

In this section we will explore how the (Horizontal Pod Autoscaler) [https://kubernetes.io/docs/tasks/run-application/horizontal-pod-autoscale/] (HPA) can be used and works within Kubernetes/OpenShift. 

> Horizontal Pod Autoscaler automatically scales the number of pods in a replication controller, deployment, replica set or stateful set based on observed CPU utilization.

We will create an HPA and then use OSToy to generate CPU intensive workloads.  We will then observe how the HPA will scale up the number of pods in order to handle the increased workloads.  
