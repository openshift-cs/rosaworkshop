## Autoscaling

In this section we will explore how the [Horizontal Pod Autoscaler](https://kubernetes.io/docs/tasks/run-application/horizontal-pod-autoscale/) (HPA) can be used and works within Kubernetes/OpenShift. 

As defined in the Kubernetes documentation:
> Horizontal Pod Autoscaler automatically scales the number of pods in a replication controller, deployment, replica set or stateful set based on observed CPU utilization.

We will create an HPA and then use OSToy to generate CPU intensive workloads.  We will then observe how the HPA will scale up the number of pods in order to handle the increased workloads.  

### Create the Horizontal Pod Autoscaler

Run the following command to create the autoscaler. The following command will create an HPA that maintains between 1 and 10 replicas of the Pods controlled by the *ostoy-microservice* deployment we created. Roughly speaking, the HPA will increase and decrease the number of replicas (via the deployment) to maintain an average CPU utilization across all Pods of 80% (since each pod requests 50 millicores, this means average CPU usage of 40 millicores)

`oc autoscale dc/ostoy-microservice --cpu-percent=80 --min=1 --max=10`

### View the current number of pods

On the left menu click on "Autoscaling" to access this portion of the workshop.  

![HPA Menu](/images/12-hpa-menu.png)

As was in the networking section you will see the total number of pods available for the microservice by counting the number of colored boxes.  In this case we have only one.  This can be verified throuhg the web UI or from the CLI.

![HPA Main](/images/12-hpa-mainpage.png)

### Increase the load

Now that we have seen that we only have one pod let's increase the workload that the pod needs to perform. Click the link in the center of the card that says "increase the load".  **Please click only *ONCE*!**

This will generate some CPU intensive calculations.  If you are curious about what it is doing you can click [here](https://github.com/0kashi/ostoy/blob/master/microservice/app.js#L32) to see.

> **Note:** You may see the page become slightly unresponsive.  This is normal so be patient while the new pods spin up.

### See the pods scale up

After about a minute we'll see the new pods show up on the page. Confirm that the pods did indeed scale up through the web UI or the CLI.

You can use the following command to see only the running microservice pods:
`oc get pods --field-selector=status.phase=Running | grep microservice`

> **Note:** The page may still lag a bit which is normal.

### Review resources in Grafana

After seeing that indeed the autoscaler did spin up new pods switch to Grafana so we can visually see the resource consumption of our pods and see how the workloads were distributed.

Go to the following url `https://grafana-openshift-monitoring.<number>.<clustername>.openshiftapps.com`

![Grafana](/images/12-grafana-home.png)

Click on *Home* on the top left and select the "K8s / Compute Resources / Namespace" dashboard.

![Select Dash](/images/12-grafana-dash.png)

Click on *Namespace* and select our project name "ostoy".

![Select NS](/images/12-grafana-ns.png)


