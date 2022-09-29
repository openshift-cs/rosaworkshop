## Create an admin user for quick access
If you want to be able to access your cluster immediately through a cluster-admin user, you can follow these steps. This is good if you need quick access to the cluster, which is great for this workshop. Though the recommended approach is to use a formal identity provider to access the cluster (and then grant that user admin privileges, if desired).

1. Run this command to create the admin user

        rosa create admin --cluster=<cluster-name>

    You will see a response like the following:

        W: It is recommended to add an identity provider to login to this cluster. See 'rosa create idp --help' for more information.
        I: Admin account has been added to cluster 'my-rosa-cluster'. It may take up to a minute for the account to become active.
        I: To login, run the following command:
        oc login https://api.my-rosa-cluster.abcd.p1.openshiftapps.com:6443 \
        --username cluster-admin \
        --password FWGYL-2mkJI-00000-00000

2. Copy the login command returned to you in the previous step and paste that into your terminal. This should log you into the cluster via the CLI so you can start using the cluster.

        $ oc login https://api.my-rosa-cluster.abcd.p1.openshiftapps.com:6443 \
        >    --username cluster-admin \
        >    --password FWGYL-2mkJI-00000-00000

        Login successful.

        You have access to 79 projects, the list has been suppressed. You can list all projects with ' projects'

        Using project "default".

3. To check that you are logged in as the admin user you can run `oc whoami`

    You will see a response like the following

        $ oc whoami
        cluster-admin

4. You can also confirm by running the following command. Only a cluster-admin user can run this without errors.

        oc get all -n openshift-apiserver

5. You can now use the cluster as an admin user, which will suffice for this workshop. Though, for any other use, it is highly recommended to set up an IdP (next step).

*[ROSA]: Red Hat OpenShift Service on AWS
*[IdP]: Identity Provider
