<!-- SPDX-License-Identifier: Apache-2.0 -->

# aws-ecr-credential

This Chart seemlessly integrate Kubernetes with AWS ECR

Simply deploy this chart to your kubernetes cluster and you will be able to pull and run images from your AWS ECR (Elastic Container Registry) in your cluster.

# Quickstart

Set up a KIND environment and Helm tools with the following script:

```sh
$ source ./scripts/kind_env.sh
```

Run the following command to register a shared AWS ECR secret alongside a service account:

```sh
$ export AWS_ECR_REGISTRY=<account>.dkr.ecr.<region>.amazonaws.com
$ export AWS_ACCESS_KEY_ID=<>
$ export AWS_SECRET_ACCESS_KEY=<>
$ kubectl create namespace my-admin-namespace
$ helm install register-aws-ecr-credential . \
  --set "mode=register" \
  --set-string "aws.ecrRegistry=$AWS_ECR_REGISTRY" \
  --set "aws.accessKeyId=$AWS_ACCESS_KEY_ID" \
  --set "aws.secretAccessKey=$AWS_SECRET_ACCESS_KEY" \
  --set "awsSecret=my-aws-secret" \
  --set "awsSecretNamespace=my-admin-namespace" \
  --set "refreshAccount=my-refresh-account"
```

After running, there should be a secret and a service account:
```sh
kubectl -n my-admin-namespace get secrets,serviceaccounts
NAME                                    TYPE                                  DATA   AGE
secret/default-token-7t22j              kubernetes.io/service-account-token   3      53s
secret/my-aws-secret                    Opaque                                3      24s
secret/my-refresh-account-token-fq2b6   kubernetes.io/service-account-token   3      24s

NAME                                SECRETS   AGE
serviceaccount/default              1         53s
serviceaccount/my-refresh-account   1         24s
```

Next, create a job+cron to populate the docker registry secret in another namespace:

```sh
$ kubectl create namespace my-user-namespace
$ helm install refresh-image-pull-secret-for-my-user . \
  --set "mode=refresh" \
  --set "awsSecret=my-aws-secret" \
  --set "awsSecretNamespace=my-admin-namespace" \
  --set "refreshAccount=my-refresh-account" \
  --set "targetSecret=my-image-pull-secret" \
  --set "targetNamespace=my-user-namespace"
```

After running, there should be a job+cronjob and a secret in the user namespace:
```sh
$ kubectl -n my-admin-namespace get jobs,cronjobs
NAME                                                  COMPLETIONS   DURATION   AGE
job.batch/refresh-image-pull-secret-for-my-user-job   1/1           5s         39s

NAME                                                       SCHEDULE      SUSPEND   ACTIVE   LAST SCHEDULE   AGE
cronjob.batch/refresh-image-pull-secret-for-my-user-cron   * */8 * * *   False     0        <none>          39s
$ kubectl -n my-user-namespace get secrets
NAME                   TYPE                                  DATA   AGE
default-token-cmp42    kubernetes.io/service-account-token   3      11m
my-image-pull-secret   kubernetes.io/dockerconfigjson        1      2m34s
```

This image pull secret can then be used in the standard way:

Example:
```yaml
apiVersion: apps/v1
kind: Deployment
spec:
  template:
    spec:
      imagePullSecrets:
      - name: my-image-pull-secret
      containers:
        - name: node
          image: node:latest
```
