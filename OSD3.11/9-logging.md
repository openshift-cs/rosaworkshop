## Logging
We will take a look at the availalbe options for logging in OpenShift Dedicated (OSD).  As OSD comes preconfigured with EFK stack (Elasticsearch, Fluentd, Kibana) it is easy to search the logs.  In this section we will take a look at two methods with which one can view their logs. First we will look at the logs directly through the pod using `oc logs`.  Second we will use Kibana to search our logs.

#### 1. Output a message to *stdout* 
Click on the *Home* menu item and then click in the message box for "Log Message (stdout)" and write any message you want to output to the *stdout* stream.  You can try "**All is well!**".  Then click "Send Message".

![Logging stdout](/images/9-ostoy-stdout.png)

#### 2. Output a message to *stderr*
Click in the message box for "Log Message (stderr)" and write any message you want to output to the *stderr* stream. You can try "**Oh no! Error!**".  Then click "Send Message".

![Logging stderr](/images/9-ostoy-stderr.png)

### Viewing pod logs

#### 3. Retrieve front end pod name
Go to the CLI and enter the following command to retrieve the name of your frontend pod which we will use to view the pod logs:

```
[okashi@ok-vm ~]# oc get pods -o name
pod/ostoy-frontend-679cb85695-5cn7x
pod/ostoy-microservice-86b4c6f559-p594d
```

So the pod name in this case is **ostoy-frontend-679cb85695-5cn7x**.  

#### 4. Retrieve the logs from the pod
Run `oc logs ostoy-frontend-679cb85695-5cn7x` and you should see your messages:

```
[okashi@ok-vm ostoy]# oc logs ostoy-frontend-679cb85695-5cn7x
[...]
ostoy-frontend-679cb85695-5cn7x: server starting on port 8080
Redirecting to /home
stdout: All is well!
stderr: Oh no! Error!
```

You should see both the *stdout* and *stderr* messages.

### Using Kibana to search logs

#### 5. View the Kibana console
Open up a new browser tab and go to `https://logs.<cluster name>.openshfit.com` to access the Kibana console.  Ensure the correct project is selected.  In the beginning of this lab we created the `ostoy` project.

![Kibana console](/images/9-kibana.png)

#### 6. View the output
In the main part of the console you should see three entries. These will match exactly what we saw in the above section (viewing through the pods).  You will see the *stdout* and *stderr* messages that we inputed earlier.  In addition to the log output you will see information about each entry.  You can see things like:
- namespace name
- pod name
- host ip address
- timestamp
- log level

![Kibana data](/images/9-logoutput.png)

If you wanted to see the data in tabular format or in JSON format you can click on the twisty-tie on the right of the row.

![Expand data](/images/9-expandlog.png)

#### 7. Filter Results
In this case since we only had 3
