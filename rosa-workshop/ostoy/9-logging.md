## Logging
We will take a look at the available options for logging in ROSA. <!-- As ROSA does not come preconfigured with a logging solution, we can easily set one up. In this section review the [install procedure](https://docs.openshift.com/dedicated/4/logging/dedicated-cluster-deploying.html#dedicated-cluster-install-deploy) for the EFK (Elasticsearch, Fluentd and Kibana) stack (via Operators), then we will take a look at three methods with which one can view their logs. -->

1. We will look at the logs directly through the pod using `oc logs`.  
1. We will forward the logs to AWS CloudWatch and view them from there.
1. On cluster logging.  This will not be covered in this workshop but you could see more information in the [About Logging](https://docs.openshift.com/rosa/observability/logging/cluster-logging.html) section of the documentation and follow the steps there to install it if you wish.

### Configure forwarding to AWS CloudWatch

!!! note
	These steps were adopted from our [Configuring log forwarding](https://docs.openshift.com/rosa/observability/logging/log_collection_forwarding/configuring-log-forwarding.html#rosa-cluster-logging-collector-log-forward-sts-cloudwatch_configuring-log-forwarding) section of the documentation.

The steps to configure ROSA to send logs to CloudWatch is not covered in this lab, as it goes beyond the lab's scope (see the docs above). However, integrating with AWS and enabling CloudWatch logging is an important aspect of ROSA's integration with AWS, so a script has been included to simplify the configuration process. The script will automatically set up AWS CloudWatch. If you're interested, you can examine the script to understand the steps involved.

1. Run the following script to configure your ROSA cluster to forward logs to CloudWatch.

	```
	curl https://raw.githubusercontent.com/openshift-cs/rosaworkshop/master/rosa-workshop/ostoy/resources/configure-cloudwatch.sh | bash
	```

	Sample Output:

	```
 	Varaibles are set...ok.
	Created policy.
	Created RosaCloudWatch-mycluster role.
	Attached role policy.
	Deploying the Red Hat OpenShift Logging Operator
	namespace/openshift-logging configured
	operatorgroup.operators.coreos.com/cluster-logging created
	subscription.operators.coreos.com/cluster-logging created
	Waiting for Red Hat OpenShift Logging Operator deployment to complete...
	Red Hat OpenShift Logging Operator deployed.
	secret/cloudwatch-credentials created
	clusterlogforwarder.logging.openshift.io/instance created
	clusterlogging.logging.openshift.io/instance created
	Complete.
	```
 
1. After a few minutes, you should begin to see log groups inside of AWS CloudWatch. Repeat this command until you do or continue the lab if you don't want to wait.

	```
	aws logs describe-log-groups --log-group-name-prefix rosa-<CLUSTER_NAME>
	```

	Sample Output:

	```
	{
 	"logGroups": [
        	{
            	"logGroupName": "rosa-mycluster.application",
            	"creationTime": 1724104537717,
            	"metricFilterCount": 0,
            	"arn": "arn:aws:logs:us-west-2:000000000000:log-group:rosa-mycluster.application:*",
            	"storedBytes": 0,
            	"logGroupClass": "STANDARD",
            	"logGroupArn": "arn:aws:logs:us-west-2:000000000000:log-group:rosa-mycluster.application"
        	},
        	{
            	"logGroupName": "rosa-mycluster.audit",
            	"creationTime": 1724104152968,
            	"metricFilterCount": 0,
            	"arn": "arn:aws:logs:us-west-2:000000000000:log-group:rosa-mycluster.audit:*",
            	"storedBytes": 0,
            	"logGroupClass": "STANDARD",
            	"logGroupArn": "arn:aws:logs:us-west-2:000000000000:log-group:rosa-mycluster.audit"
        	},
	...
	```

### Output data to the streams/logs

1. Output a message to *stdout*
Click on the *Home* menu item and then click in the message box for "Log Message (stdout)" and write any message you want to output to the *stdout* stream.  You can try "**All is well!**".  Then click "Send Message".

	![Logging stdout](images/9-ostoy-stdout.png)

2. Output a message to *stderr*
Click in the message box for "Log Message (stderr)" and write any message you want to output to the *stderr* stream. You can try "**Oh no! Error!**".  Then click "Send Message".

	![Logging stderr](images/9-ostoy-stderr.png)

### View application logs using `oc`

1. Go to the CLI and enter the following command to retrieve the name of your frontend pod which we will use to view the pod logs:

	```
	$ oc get pods -o name
	pod/ostoy-frontend-679cb85695-5cn7x
	pod/ostoy-microservice-86b4c6f559-p594d
	```

So the pod name in this case is **ostoy-frontend-679cb85695-5cn7x**.  

1. Run `oc logs ostoy-frontend-679cb85695-5cn7x` and you should see your messages:

	```
	$ oc logs ostoy-frontend-679cb85695-5cn7x
	[...]
	ostoy-frontend-679cb85695-5cn7x: server starting on port 8080
	Redirecting to /home
	stdout: All is well!
	stderr: Oh no! Error!
	```

You should see both the *stdout* and *stderr* messages.


### View logs with CloudWatch
1. Access the web console for your AWS account and go to CloudWatch.
1. Click on *Logs* > *Log groups* in the left menu to see the different groups of logs depending on what you selected during installation. If you followed the previous steps you should see 3 groups.  One for `rosa-<CLUSTER_NAME>.application`, `rosa-<CLUSTER_NAME>.audit`, and `rosa-<CLUSTER_NAME>.infrastructure`.

	![cloudwatch](images/9-cw.png)

1. Click on `rosa-<CLUSTER_NAME>.application`
1. Click on the log stream for the "frontend" pod.  It will be titled something like `kubernetes.var[...]ostoy-frontend-[...]`

	![cloudwatch2](images/9-logstream.png)

1. Filter for "stdout" and "stderr" the expand the row to show the message we had entered earlier along with much other information.

	![cloudwatch2](images/9-stderr.png)


1. We can also see other messages in our logs from the app. Return to the LogStreams and select the microservice pod. Enter "microservice" in the search bar, and expand one of the entries. This shows us the color received from the microservice and which pod sent that color to our frontend pod.

	![messages](images/9-messages.png)


You can also use some of the other features of CloudWatch to obtain useful information. But [AWS CloudWatch](https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/WhatIsCloudWatch.html) is beyond the scope of this tutorial.

<!--
### View logs with Kibana
!!! note
 		In order to use EFK, this section assumes that you have successfully completed the steps outlined in [Installing OpenShift Logging](https://docs.openshift.com/container-platform/latest/logging/cluster-logging-deploying.html).

1. Run the following command to get the route for the Kibana console:

		oc get route -n openshift-logging

1. Open up a new browser tab and paste the URL. You will first have to define index patterns.  Please see the [Defining Kibana index patterns](https://docs.openshift.com/container-platform/latest/logging/cluster-logging-deploying.html#cluster-logging-visualizer-indices_cluster-logging-deploying) section of the documentation for further instructions on doing so.

#### Familiarization with the data
In the main part of the console you should see three entries. These will contain what we saw in the above section (viewing through the pods).  You will see the *stdout* and *stderr* messages that we inputted earlier (though you may not see it right away as we might have to filter for it).  In addition to the log output you will see information about each entry.  You can see things like:

- namespace name
- pod name
- host ip address
- timestamp
- log level
- message

![Kibana data](images/9-logoutput.png)

You will also see that there is data from multiple sources and multiple messages.  If we expand one of the twisty-ties we can see further details

![log data](images/9-logdata.png)


#### Filtering Results
Let's look for any errors encountered in our app.  Since we have many log entries (most from the previous networking section) we may need to filter to make it easier to find the errors.  To find the error message we outputted to *stderr* lets create a filter.  

- Click on "Add a filter+" under the search bar on the upper left.
- For "Fields..." select (or type) "level"
- For "Operators" select "is"
- In "Value..." type in "err"
- Click "Save"

![Expand data](images/9-filtererr.png)

You should see now only one row is returned that contains our error message.

![Expand data](images/9-erronly.png)

!!! note
	If nothing is returned, depending on how much time has elapsed since you've outputted the messages to the *stdout* and *stderr* streams you may need to set the proper time frame for the filter.  If you are following this lab consistently then the default should be fine.  Otherwise, in the Kibana console, click on the top right where it should say "Last 15 minutes" and click on "Quick" then "Last 1 hour" (though adjust to your situation as needed).
-->
