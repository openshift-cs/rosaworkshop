## Autoscaling

In this section we will explore how the [Horizontal Pod Autoscaler](https://kubernetes.io/docs/tasks/run-application/horizontal-pod-autoscale/) (HPA) can be used and works within Kubernetes/OpenShift. 

As defined in the Kubernetes documentation:
> Horizontal Pod Autoscaler automatically scales the number of pods in a replication controller, deployment, replica set or stateful set based on observed CPU utilization.

We will create an HPA and then use OSToy to generate CPU intensive workloads.  We will then observe how the HPA will scale up the number of pods in order to handle the increased workloads.  

#### 1. Create the Horizontal Pod Autoscaler

Run the following command to create the autoscaler. This will create an HPA that maintains between 1 and 10 replicas of the Pods controlled by the *ostoy-microservice* DeploymentConfig created. Roughly speaking, the HPA will increase and decrease the number of replicas (via the deployment) to maintain an average CPU utilization across all Pods of 80% (since each pod requests 50 millicores, this means average CPU usage of 40 millicores)

`oc autoscale dc/ostoy-microservice --cpu-percent=80 --min=1 --max=10`

#### 2. View the current number of pods

In the OSToy app in the left menu click on "Autoscaling" to access this portion of the workshop.  

![HPA Menu](images/12-hpa-menu.png)

As was in the networking section you will see the total number of pods available for the microservice by counting the number of colored boxes.  In this case we have only one.  This can be verified through the web UI or from the CLI.

You can use the following command to see the running microservice pods only:
`oc get pods --field-selector=status.phase=Running | grep microservice`

![HPA Main](images/12-hpa-mainpage.png)

#### 3. Increase the load

Now that we know that we only have one pod let's increase the workload that the pod needs to perform. Click the link in the center of the card that says "increase the load".  **Please click only *ONCE*!**

This will generate some CPU intensive calculations.  (If you are curious about what it is doing you can click [here](https://github.com/openshift-cs/ostoy/blob/master/microservice/app.js#L32)).

> **Note:** The page may become slightly unresponsive.  This is normal; so be patient while the new pods spin up.

#### 4. See the pods scale up

After about a minute the new pods will show up on the page (represented by the colored rectangles). Confirm that the pods did indeed scale up through the OpenShift Web Console or the CLI (you can use the command above).

> **Note:** The page may still lag a bit which is normal.

#### 5. Review resources in Grafana

After confirming that the autoscaler did spin up new pods, switch to Grafana to visually see the resource consumption of the pods and see how the workloads were distributed.

Go to the following url `https://grafana-openshift-monitoring.<number>.<clustername>.openshiftapps.com`

![Grafana](images/12-grafana-home.png)

Click on *Home* on the top left and select the *"K8s / Compute Resources / Namespace"* dashboard.

![Select Dash](images/12-grafana-dash.png)

Click on *Namespace* and select our project name "ostoy-s2i".

![Select NS](images/12-grafana-ns.png)

Colorful graphs will appear showing resource usage across CPU and memory.  The top graph will show recent CPU consumption per pod and the lower graph will indicate memory usage.  Looking at this graph you can see how things developed. As soon as the load started to increase (A), three new pods started to spin up (B, C, D). The thickness of each graph is its CPU consumption indicating which pods handled more load.  We also see that after the load decreased, the pods were spun back down (E).

![CPU](images/12-grafana-cpu.png)

Mouse over the graph and the tool will display the names and corresponding CPU consumption of each pod as seen below.

![CPU](images/12-grafana-metrics.png)
