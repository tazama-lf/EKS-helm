# helm
All the helm charts for running the FRMS platform

link to deployment documentation - https://frmscoe.atlassian.net/wiki/spaces/FRMS/pages/1741808/FRMS+Deployment+Guide

Step 1 : Helm charts 
In this section we will be running through the initial setup of FRMS on a cluster. A helm subchart will be used to install multiple setups for all the different helm files based in one subchart for easier installation, these will include services , ingresses , pods, replicate-sets etc… 

Namespaces that need to be added to your cluster:

cicd

default

development

ingress-nginx

openfaas

openfaas-fn

 

The list below are the different helm charts:

Openfaas

Nifi

ElasticSearch

ArangoDB (single deployment)

ArangoDb Ingress Proxy

Jenkins

Redis

KeyCloak

Vault

nginx ingress controller

APM (Elasticsearch)

Logstash (Elasticsearch)

 

ie: There is another HELM chart for the arangodb clustered version which is referenced on the following page. The single deployment version is used instead of the cluster due to functionality missing/needed on the enterprise option.

ArangoDb Cluster installation 

Repo 
git@github.com:frmscoe/helm.git

Add Helm repository
In your cluster open up a new terminal and run the following commands 

helm repo add FRMS frmscoe/helm 

 

helm repo update

 

 

 

Install the chart
Install the helm sub-chart with a release name frmscoe:

helm install FRMS ./FRMS/helm

 

Extra Information: Helm | Helm Install 

 

Uninstalling the chart
To uninstall/delete the FRMSdeployment:

helm uninstall FRMS

 

Step 2 : Configuration
 

Each chart has defaulted configuration setup to get the platform in the correct state to be used  this includes ports , namespaces , secrets , ingresses and storage to name a few. This step can be skipped if not needed ,the below  is just additional configuration that might be needed if you need additional storage etc…

NIFI configuration 
Configure the chart
The following items can be set via --set flag during installation or configured by editing the values.yaml file directly (need to download the chart first).

Configure how to expose nifi service
Ingress: The ingress controller must be installed in the Kubernetes cluster.

ClusterIP: Exposes the service on a cluster-internal IP. Choosing this value makes the service only reachable from within the cluster.

NodePort: Exposes the service on each Node’s IP at a static port (the NodePort). You’ll be able to contact the NodePort service, from outside the cluster, by requesting NodeIP:NodePort.

LoadBalancer: Exposes the service externally using a cloud provider’s load balancer.

Configure how to persist data
Disable: The data does not survive the termination of a pod.

Persistent Volume Claim(default): A default StorageClass is needed in the Kubernetes cluster to dynamically provision the volumes. Specify another StorageClass in the storageClass or set existingClaim if you have already existing persistent volumes to use.

Configure authentication
By default, the authentication is a Single-User authentication. You can optionally enable ldap or oidc to provide an external authentication. See the configuration section or doc folder for more details.

Use custom processors
To add custom processors, the values.yaml file nifi section should contain the following options, where CUSTOM_LIB_FOLDER should be replaced by the path where the libs are:


  extraVolumeMounts:
    - name: mycustomlibs
      mountPath: /opt/configuration_resources/custom_lib
  extraVolumes: # this will create the volume from the directory
    - name: mycustomlibs
      hostPath:
        path: "CUSTOM_LIB_FOLDER"
  properties:
    customLibPath: "/opt/configuration_resources/custom_lib"
Configure prometheus monitoring
You first need monitoring to be enabled which can be accomplished by enabling the appropriate metrics flag (metrics.prometheus.enabled to true). To enable the creation of prometheus metrics within Nifi we need to create a Reporting Task. Login to the Nifi UI and go to the Hamburger menu on the top right corner, click Controller Settings --> Reporting Tasks After that use the + icon to add a task. Click on the Reporting in the wordcloud on the left and select PrometheusReportingTask --> change Send JVM metrics to true and click on the play button to enable this task.

 

Extra Information: https://backstage.rockcontent.com/nifi-cluster/

                                 Deploy Apache NiFi as Statefullset 

                                 Apache NiFi Walkthroughs 

Openfaas configuration 
Configuration of the controller
faas-netes can be configured with environment variables, but for a full set of options see the helm chart.

Option

Usage

httpProbe

Boolean - use http probe type for function readiness and liveness. Default: false

write_timeout

HTTP timeout for writing a response body from your function (in seconds). Default: 60s

read_timeout

HTTP timeout for reading the payload from the client caller (in seconds). Default: 60s

image_pull_policy

Image pull policy for deployed functions (Always, IfNotPresent, Never). Default: Always

gateway.resources

CPU/Memory resources requests/limits (memory: 120Mi, cpu: 50m)

faasnetes.resources

CPU/Memory resources requests/limits (memory: 120Mi, cpu: 50m)

operator.resources

CPU/Memory resources requests/limits (memory: 120Mi, cpu: 50m)

queueWorker.resources

CPU/Memory resources requests/limits (memory: 120Mi, cpu: 50m)

prometheus.resources

CPU/Memory resources requests/limits (memory: 512Mi)

alertmanager.resources

CPU/Memory resources requests/limits (memory: 25Mi)

nats.resources

CPU/Memory resources requests/limits (memory: 120Mi)

faasIdler.resources

CPU/Memory resources requests/limits (memory: 64Mi)

basicAuthPlugin.resources

CPU/Memory resources requests/limits (memory: 50Mi, cpu: 20m)

Readiness checking
The readiness checking for functions assumes you are using our function watchdog which writes a .lock file in the default "tempdir" within a container. To see this in action you can delete the .lock file in a running Pod with kubectl exec and the function will be re-scheduled.

Namespaces
By default all OpenFaaS functions and services are deployed to the openfaas and openfaas-fn namespaces. To alter the namespace use the helm chart.

Ingress
To configure ingress see the helm chart. By default NodePorts are used. These are listed in the deployment guide.

By default functions are exposed at http://gateway:8080/function/NAME.

You can also use the IngressOperator to set up custom domains and HTTP paths

 

Elastic configuration 
Usage notes
This repo includes a number of examples configurations which can be used as a reference. They are also used in the automated testing of this chart.

Automated testing of this chart is currently only run against GKE (Google Kubernetes Engine).

The chart deploys a StatefulSet and by default will do an automated rolling update of your cluster. It does this by waiting for the cluster health to become green after each instance is updated. If you prefer to update manually you can set OnDelete updateStrategy.

It is important to verify that the JVM heap size in esJavaOpts and to set the CPU/Memory resources to something suitable for your cluster.

To simplify chart and maintenance each set of node groups is deployed as a separate Helm release. Take a look at the multi example to get an idea for how this works. Without doing this it isn't possible to resize persistent volumes in a StatefulSet. By setting it up this way it makes it possible to add more nodes with a new storage size then drain the old ones. It also solves the problem of allowing the user to determine which node groups to update first when doing upgrades or changes.

We have designed this chart to be very un-opinionated about how to configure Elasticsearch. It exposes ways to set environment variables and mount secrets inside of the container. Doing this makes it much easier for this chart to support multiple versions with minimal changes.

 

How to deploy this chart on a specific K8S distribution?
This chart is designed to run on production scale Kubernetes clusters with multiple nodes, lots of memory and persistent storage. For that reason it can be a bit tricky to run them against local Kubernetes environments such as Minikube.

This chart is highly tested with GKE, but some K8S distribution also requires specific configurations.

We provide examples of configuration for the following K8S providers:

Docker for Mac

KIND

Minikube

MicroK8S

OpenShift

How to deploy dedicated nodes types?
All the Elasticsearch pods deployed share the same configuration. If you need to deploy dedicated nodes types (for example dedicated master and data nodes), you can deploy multiple releases of this chart with different configurations while they share the same clusterName value.

For each Helm release, the nodes types can then be defined using roles value.

An example of Elasticsearch cluster using 2 different Helm releases for master, data and coordinating nodes can be found in examples/multi.

Coordinating nodes
Every node is implicitly a coordinating node. This means that a node that has an explicit empty list of roles will only act as a coordinating node.

When deploying coordinating-only node with Elasticsearch chart, it is required to define the empty list of roles in both roles value and node.roles settings:


roles: []

esConfig:
  elasticsearch.yml: |
    node.roles: []
More details in #1186 (comment)

Clustering and Node Discovery
This chart facilitates Elasticsearch node discovery and services by creating two Service definitions in Kubernetes, one with the name $clusterName-$nodeGroup and another named $clusterName-$nodeGroup-headless. Only Ready pods are a part of the $clusterName-$nodeGroup service, while all pods ( Ready or not) are a part of $clusterName-$nodeGroup-headless.

If your group of master nodes has the default nodeGroup: master then you can just add new groups of nodes with a different nodeGroup and they will automatically discover the correct master. If your master nodes have a different nodeGroup name then you will need to set masterService to $clusterName-$masterNodeGroup.

The chart value for masterService is used to populate discovery.zen.ping.unicast.hosts , which Elasticsearch nodes will use to contact master nodes and form a cluster. Therefore, to add a group of nodes to an existing cluster, setting masterService to the desired Service name of the related cluster is sufficient.

How to deploy clusters with security (authentication and TLS) enabled?
This Helm chart can generate a [Kubernetes Secret][] or use an existing one to setup Elastic credentials.

This Helm chart can use existing [Kubernetes Secret][] to setup Elastic certificates for example. These secrets should be created outside of this chart and accessed using environment variables and volumes.

This chart is setting TLS and creating a certificate by default, but you can also provide your own certs as a K8S secret. An example of configuration for providing existing certificates can be found in examples/security.

 

How to install plugins?
The recommended way to install plugins into our Docker images is to create a custom Docker image.

The Dockerfile would look something like:


ARG elasticsearch_version
FROM docker.elastic.co/elasticsearch/elasticsearch:${elasticsearch_version}

RUN bin/elasticsearch-plugin install --batch repository-gcs

And then updating the image in values to point to your custom image.

There are a couple reasons we recommend this.

Tying the availability of Elasticsearch to the download service to install plugins is not a great idea or something that we recommend. Especially in Kubernetes where it is normal and expected for a container to be moved to another host at random times.

Mutating the state of a running Docker image (by installing plugins) goes against best practices of containers and immutable infrastructure.

How to use the keystore?
Basic example

Create the secret, the key name needs to be the keystore key path. In this example we will create a secret from a file and from a literal string.


kubectl create secret generic encryption-key --from-file=xpack.watcher.encryption_key=./watcher_encryption_key
kubectl create secret generic slack-hook --from-literal=xpack.notification.slack.account.monitoring.secure_url='https://hooks.slack.com/services/asdasdasd/asdasdas/asdasd'

To add these secrets to the keystore:


keystore:
  - secretName: encryption-key
  - secretName: slack-hook

Multiple keys
All keys in the secret will be added to the keystore. To create the previous example in one secret you could also do:


kubectl create secret generic keystore-secrets --from-file=xpack.watcher.encryption_key=./watcher_encryption_key --from-literal=xpack.notification.slack.account.monitoring.secure_url='https://hooks.slack.com/services/asdasdasd/asdasdas/asdasd'

keystore:
  - secretName: keystore-secrets

Custom paths and keys
If you are using these secrets for other applications (besides the Elasticsearch keystore) then it is also possible to specify the keystore path and which keys you want to add. Everything specified under each keystore item will be passed through to the volumeMounts section for mounting the secret. In this example we will only add the slack_hook key from a secret that also has other keys. Our secret looks like this:


kubectl create secret generic slack-secrets --from-literal=slack_channel='#general' --from-literal=slack_hook='https://hooks.slack.com/services/asdasdasd/asdasdas/asdasd'

We only want to add the slack_hook key to the keystore at path xpack.notification.slack.account.monitoring.secure_url:


keystore:
  - secretName: slack-secrets
    items:
    - key: slack_hook
      path: xpack.notification.slack.account.monitoring.secure_url

You can also take a look at the config example which is used as part of the automated testing pipeline.

How to enable snapshotting?

Install your snapshot plugin into a custom Docker image following the how to install plugins guide.

Add any required secrets or credentials into an Elasticsearch keystore following the how to use the keystore guide.

Configure the snapshot repository as you normally would.

To automate snapshots you can use Snapshot Lifecycle Management or a tool like curator.

How to configure templates post-deployment?
You can use postStart lifecycle hooks to run code triggered after a container is created.

Here is an example of postStart hook to configure templates:


lifecycle:
  postStart:
    exec:
      command:
        - bash
        - -c
        - |
          #!/bin/bash
          # Add a template to adjust number of shards/replicas
          TEMPLATE_NAME=my_template
          INDEX_PATTERN="logstash-*"
          SHARD_COUNT=8
          REPLICA_COUNT=1
          ES_URL=http://localhost:9200
          while [[ "$(curl -s -o /dev/null -w '%{http_code}\n' $ES_URL)" != "200" ]]; do sleep 1; done
          curl -XPUT "$ES_URL/_template/$TEMPLATE_NAME" -H 'Content-Type: application/json' -d'{"index_patterns":['\""$INDEX_PATTERN"\"'],"settings":{"number_of_shards":'$SHARD_COUNT',"number_of_replicas":'$REPLICA_COUNT'}}'
 

Extra Information:  How To Set Up an Elasticsearch, Fluentd and Kibana (EFK) Logging Stack on Kubernetes  | DigitalOcean

Jenkins configuration 
There is no additional configuration setup needed for Jenkins but for reference please see readme below


Jenkins README.md
03 Aug 2022, 01:48 PM
Redis configuration 
Redis™ common configuration parameters
Name

Description

Value

architecture

Redis™ architecture. Allowed values: standalone or replication

replication

auth.enabled

Enable password authentication

true

auth.sentinel

Enable password authentication on sentinels too

true

auth.password

Redis™ password

""

auth.existingSecret

The name of an existing secret with Redis™ credentials

""

auth.existingSecretPasswordKey

Password key to be retrieved from existing secret

""

auth.usePasswordFiles

Mount credentials as files instead of using an environment variable

false

commonConfiguration

Common configuration to be added into the ConfigMap

""

existingConfigmap

The name of an existing ConfigMap with your custom configuration for Redis™ nodes

""

 

Bootstrapping with an External Cluster
This chart is equipped with the ability to bring online a set of Pods that connect to an existing Redis deployment that lies outside of Kubernetes. This effectively creates a hybrid Redis Deployment where both Pods in Kubernetes and Instances such as Virtual Machines can partake in a single Redis Deployment. This is helpful in situations where one may be migrating Redis from Virtual Machines into Kubernetes, for example. To take advantage of this, use the following as an example configuration:


replica:
  externalMaster:
    enabled: true
    host: external-redis-0.internal
sentinel:
  externalMaster:
    enabled: true
    host: external-redis-0.internal
⚠️ This is currently limited to clusters in which Sentinel and Redis run on the same node! ⚠️

Please also note that the external sentinel must be listening on port 26379, and this is currently not configurable.

Once the Kubernetes Redis Deployment is online and confirmed to be working with the existing cluster, the configuration can then be removed and the cluster will remain connected.

External DNS

This chart is equipped to allow leveraging the ExternalDNS project. Doing so will enable ExternalDNS to publish the FQDN for each instance, in the format of <pod-name>.<release-name>.<dns-suffix>. Example, when using the following configuration:


useExternalDNS:
  enabled: true
  suffix: prod.example.org
  additionalAnnotations:
    ttl: 10
On a cluster where the name of the Helm release is a, the hostname of a Pod is generated as: a-redis-node-0.a-redis.prod.example.org. The IP of that FQDN will match that of the associated Pod. This modifies the following parameters of the Redis/Sentinel configuration using this new FQDN:

replica-announce-ip

known-sentinel

known-replica

announce-ip

⚠️ This requires a working installation of external-dns to be fully functional. ⚠️

See the official ExternalDNS documentation for additional configuration options.

Cluster topologies
Default: Master-Replicas

When installing the chart with architecture=replication, it will deploy a Redis™ master StatefulSet (only one master node allowed) and a Redis™ replicas StatefulSet. The replicas will be read-replicas of the master. Two services will be exposed:

Redis™ Master service: Points to the master, where read-write operations can be performed

Redis™ Replicas service: Points to the replicas, where only read operations are allowed.

In case the master crashes, the replicas will wait until the master node is respawned again by the Kubernetes Controller Manager.

Standalone

When installing the chart with architecture=standalone, it will deploy a standalone Redis™ StatefulSet (only one node allowed). A single service will be exposed:

Redis™ Master service: Points to the master, where read-write operations can be performed

Master-Replicas with Sentinel
When installing the chart with architecture=replication and sentinel.enabled=true, it will deploy a Redis™ master StatefulSet (only one master allowed) and a Redis™ replicas StatefulSet. In this case, the pods will contain an extra container with Redis™ Sentinel. This container will form a cluster of Redis™ Sentinel nodes, which will promote a new master in case the actual one fails. In addition to this, only one service is exposed:

Redis™ service: Exposes port 6379 for Redis™ read-only operations and port 26379 for accessing Redis™ Sentinel.

For read-only operations, access the service using port 6379. For write operations, it's necessary to access the Redis™ Sentinel cluster and query the current master using the command below (using redis-cli or similar):


SENTINEL get-master-addr-by-name <name of your MasterSet. e.g: mymaster>

This command will return the address of the current master, which can be accessed from inside the cluster.

In case the current master crashes, the Sentinel containers will elect a new master node.

Using a password file
To use a password file for Redis™ you need to create a secret containing the password and then deploy the chart using that secret.

Refer to the chart documentation for more information on using a password file for Redis™.

 


Redis README.md
03 Aug 2022, 01:48 PM
 

KeyCloak configuration 
Usage of the tpl Function
The tpl function allows us to pass string values from values.yaml through the templating engine. It is used for the following values:

extraInitContainers

extraContainers

extraEnv

extraEnvFrom

affinity

extraVolumeMounts

extraVolumes

livenessProbe

readinessProbe

startupProbe

topologySpreadConstraints

Additionally, custom labels and annotations can be set on various resources the values of which being passed through tpl as well.

It is important that these values be configured as strings. Otherwise, installation will fail. See example for Google Cloud Proxy or default affinity configuration in values.yaml.

JVM Settings
Keycloak sets the following system properties by default: -Djava.net.preferIPv4Stack=true -Djboss.modules.system.pkgs=$JBOSS_MODULES_SYSTEM_PKGS -Djava.awt.headless=true

You can override these by setting the JAVA_OPTS environment variable. Make sure you configure container support. This allows you to only configure memory using Kubernetes resources and the JVM will automatically adapt.


extraEnv: |
  - name: JAVA_OPTS
    value: >-
      -XX:+UseContainerSupport
      -XX:MaxRAMPercentage=50.0
      -Djava.net.preferIPv4Stack=true
      -Djboss.modules.system.pkgs=$JBOSS_MODULES_SYSTEM_PKGS
      -Djava.awt.headless=true
Database Setup
By default, Bitnami's PostgreSQL chart is deployed and used as database. Please refer to this chart for additional PostgreSQL configuration options.

Using an External Database
The Keycloak Docker image supports various database types. Configuration happens in a generic manner.

Using a Secret Managed by the Chart
The following examples uses a PostgreSQL database with a secret that is managed by the Helm chart.


postgresql:
  # Disable PostgreSQL dependency
  enabled: false

extraEnv: |
  - name: DB_VENDOR
    value: postgres
  - name: DB_ADDR
    value: mypostgres
  - name: DB_PORT
    value: "5432"
  - name: DB_DATABASE
    value: mydb

extraEnvFrom: |
  - secretRef:
      name: '{{ include "keycloak.fullname" . }}-db'

secrets:
  db:
    stringData:
      DB_USER: '{{ .Values.dbUser }}'
      DB_PASSWORD: '{{ .Values.dbPassword }}'
dbUser and dbPassword are custom values you'd then specify on the commandline using --set-string.

Using an Existing Secret
The following examples uses a PostgreSQL database with a secret. Username and password are mounted as files.


postgresql:
  # Disable PostgreSQL dependency
  enabled: false

extraEnv: |
  - name: DB_VENDOR
    value: postgres
  - name: DB_ADDR
    value: mypostgres
  - name: DB_PORT
    value: "5432"
  - name: DB_DATABASE
    value: mydb
  - name: DB_USER_FILE
    value: /secrets/db-creds/user
  - name: DB_PASSWORD_FILE
    value: /secrets/db-creds/password

extraVolumeMounts: |
  - name: db-creds
    mountPath: /secrets/db-creds
    readOnly: true

extraVolumes: |
  - name: db-creds
    secret:
      secretName: keycloak-db-creds
Creating a Keycloak Admin User
The Keycloak Docker image supports creating an initial admin user. It must be configured via environment variables:

KEYCLOAK_USER or KEYCLOAK_USER_FILE

KEYCLOAK_PASSWORD or KEYCLOAK_PASSWORD_FILE

Please refer to the section on database configuration for how to configure a secret for this.

High Availability and Clustering
For high availability, Keycloak must be run with multiple replicas (replicas > 1). The chart has a helper template (keycloak.serviceDnsName) that creates the DNS name based on the headless service.

DNS_PING Service Discovery

JGroups discovery via DNS_PING can be configured as follows:


extraEnv: |
  - name: JGROUPS_DISCOVERY_PROTOCOL
    value: dns.DNS_PING
  - name: JGROUPS_DISCOVERY_PROPERTIES
    value: 'dns_query={{ include "keycloak.serviceDnsName" . }}'
  - name: CACHE_OWNERS_COUNT
    value: "2"
  - name: CACHE_OWNERS_AUTH_SESSIONS_COUNT
    value: "2"
KUBE_PING Service Discovery

Recent versions of Keycloak include a new Kubernetes native KUBE_PING service discovery protocol. This requires a little more configuration than DNS_PING but can easily be achieved with the Helm chart.

As with DNS_PING some environment variables must be configured as follows:


extraEnv: |
  - name: JGROUPS_DISCOVERY_PROTOCOL
    value: kubernetes.KUBE_PING
  - name: KUBERNETES_NAMESPACE
    valueFrom:
      fieldRef:
        apiVersion: v1
        fieldPath: metadata.namespace
  - name: CACHE_OWNERS_COUNT
    value: "2"
  - name: CACHE_OWNERS_AUTH_SESSIONS_COUNT
    value: "2"
However, the Keycloak Pods must also get RBAC permissions to get and list Pods in the namespace which can be configured as follows:


rbac:
  create: true
  rules:
    - apiGroups:
        - ""
      resources:
        - pods
      verbs:
        - get
        - list
Autoscaling
Due to the caches in Keycloak only replicating to a few nodes (two in the example configuration above) and the limited controls around autoscaling built into Kubernetes, it has historically been problematic to autoscale Keycloak. However, in Kubernetes 1.18 additional controls were introduced which make it possible to scale down in a more controlled manner.

The example autoscaling configuration in the values file scales from three up to a maximum of ten Pods using CPU utilization as the metric. Scaling up is done as quickly as required but scaling down is done at a maximum rate of one Pod per five minutes.

Autoscaling can be enabled as follows:


autoscaling:
  enabled: true
KUBE_PING service discovery seems to be the most reliable mechanism to use when enabling autoscaling, due to being faster than DNS_PING at detecting changes in the cluster.

 


Keycloak README.md
03 Aug 2022, 01:48 PM
 

ArangoDB configuration 
There is no additional configuration setup needed for ArangoDB but for reference please see readme below


ArangoDB README.md
03 Aug 2022, 01:48 PM
 

Step 3 : Running Jenkins jobs to install processors 
In this step we will be running you through the deployments of the different processors which needs to be run into the FRMS cluster through Jenkins which include the following:

 Populate_arango - This is to populate the arangoDB with the correct configuration used within the system





 Update Jenkins variables -  To update the variables go to Dashboard>Manage Jenkins>Configure System>Global Properties . These are the variables that used in the deployment jobs for the rules and rule processors.

Variables to be updated:

APMToken
ArangoDbPassword
ArangoDbURL
ArangoToken
OpenfaasPassword
OpenfaasURL
RedisHost
RedisPassword
RuleVersion




NOTE: Additional work will be done changing these variables to Vault secrets for the sensitive information.


Nuxeo Case Management - If the opensource case management system is required please run the following jobs to build the docker image and deploy Nuxeo to your cluster.





 Deploying All Rules and Rule Processors


Once all these processors have been run you will see them both in Openfaas and on your FRMS Cluster



 

Step 4 : Conclusion 
 

Now that the Helm chart and Jenkins deployments have been run , you will have a working cluster
