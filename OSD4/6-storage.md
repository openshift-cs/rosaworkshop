## Using Persistent Volumes

In this section we will execute a simple example of using persistent storage by creating a file that will be stored on a Persistent Volume in our cluster and then confirm that it will "persist" across pod failures and recreation.

#### 1. View Persistent Volume Claims
Inside the OpenShift web UI click on *Storage* in the left menu then *Persistent Volume Claims*. You will then see a list of all persistent volume claims that our application has made.  In this case there is just one called "ostoy-pvc".  If you click on it you will also see other pertinent information such as whether it is bound or not, size, access mode and age.  

In this case the mode is RWO (Read-Write-Once) which means that the volume can only be mounted to one node, but the pod(s) can both read and write to that volume.  As Persistent Volumes in OSD are backed by EBS it only supports RWO.  ([See here for more info on access modes](https://docs.openshift.com/dedicated/4/storage/understanding-persistent-storage.html#pv-access-modes_understanding-persistent-storage))

#### 2. Create a file to store
In the OSToy app click on *Persistent Storage* in the left menu.  In the "Filename" area enter a filename for the file you will create (ie: "test-pv.txt"). Please use a *".txt"* extension so that the file will be visible in the browser.

Underneath that, in the "File Contents" box, enter text to be stored in the file. (ie: "OpenShift is the greatest thing since sliced bread!" or "test" :) ).  Then click "Create file".

![Create File](images/6-ostoy-createfile.png)

#### 3. View the file created
You will then see the file you created appear above, under "Existing files".  Click on the file and you will see the filename and the contents you entered.

![View File](images/6-ostoy-viewfile.png)

#### 4. Kill the pod
We now want to kill the pod and ensure that the new pod that spins up will be able to see the file we created. Exactly like we did in the previous section. 

Click on *Home* in the left menu.

Click on the "Crash pod" button.  (You can enter a message if you'd like).

#### 5. Ensure the file is still there
Once the pod is back up, click on *Persistent Storage* in the left menu

You will see the file you created is still there and you can open it to view its contents to confirm.

![ExistingFile](images/6-ostoy-existingfile.png)

#### 6. Confirm via the container
Now let's confirm that it's actually there by using the CLI and checking if it is available to the container.  If you looked inside the deployment YAML file, we mounted the directory `/var/demo-files` to our PVC.  So get the name of your front-end pod

`oc get pods`

then get an SSH session into the container

`oc rsh <podname>`

then `cd /var/demo-files`

if you enter `ls` you can see all the files you created.  Next, let's open the file we created and see the contents

`cat test-pv.txt`

You should see the text you entered in the UI.  The whole flow would look like the below:

```shell
$ oc get pods
NAME                                  READY     STATUS    RESTARTS   AGE
ostoy-frontend-5fc8d486dc-wsw24       1/1       Running   0          18m
ostoy-microservice-6cf764974f-hx4qm   1/1       Running   0          18m

$ oc rsh ostoy-frontend-5fc8d486dc-wsw24
/ $ cd /var/demo_files/

/var/demo_files $ ls
lost+found   test-pv.txt

/var/demo_files $ cat test-pv.txt 
OpenShift is the greatest thing since sliced bread!
```
#### 7. Exit the session
Then exit the session by typing `exit`. You will then be in your CLI.
