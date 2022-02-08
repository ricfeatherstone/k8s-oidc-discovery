# OIDC Discovery Demo

This demo utilises the OIDC Discovery Feature in combination with AWS Federated Identity to grant read access to
S3 to containers running in EKS, GKE and AKS.

## Build the Tools

```shell
make build-tools
```

## Create the clusters

```shell
make clusters-create
```

Create an EKS, GKE and AKS cluster, kubeconfig files are stored in the [.kube](../.kube) directory.

At the time of writing the OIDC Issuer feature is in preview and needs to be specifically enabled.

## Retrieve the issuer urls for each cluster.

```shell
make eks-issuer gke-issuer aks-issuer
```

## Get the fingerprints for each issuer

```shell
make eks-fingerprint
make gke-fingerprint
make aks-fingerprint
```

## Update Terraform Variables for the AWS IAM OIDC Provider Configuration

Using the issuer url and fingerprint for each issuer from above, replace the `REPLACE_ME` placeholders in the following 
files.

* [variables.tf](../terraform/variables.tf)

## Create the AWS IAM Role and OIDC Provider Resources

```shell
make terraform-apply
```

## Update IAM Role Configuration on Kubernetes Configuration

Obtain the ARN for the `oidc-discovery-demo` IAM Role.

```shell
make iam-role-arn
```

Replace the `REPLACE_ME` placeholders in the following files.

* [deploy.yaml](../manifests/manual/deploy.yaml)
* [sa.yaml](../manifests/webhook-enabled/sa.yaml)

## Deploy with Manual Configuration

```shell
make deploy-manual
```

View the JWT Claims

```shell
KUBECONFIG=.kube/aws make jwt-claims
KUBECONFIG=.kube/gcp make jwt-claims
KUBECONFIG=.kube/azure make jwt-claims
```

View the OIDC Discovery Document and JWKS

```shell
KUBECONFIG=.kube/aws make oidc-discovery
KUBECONFIG=.kube/gcp make oidc-discovery
KUBECONFIG=.kube/azure make oidc-discovery
```

## Obtain Dynamic Credentials and List S3 Buckets with Manual Configuration

```shell
KUBECONFIG=.kube/aws make list-buckets
KUBECONFIG=.kube/gcp make list-buckets
KUBECONFIG=.kube/azure make list-buckets
```

Cleanup 

```shell
make delete-manual
```

## Obtain Dynamic Credentials and List S3 Buckets Using the AWS Pod Identity Webhook

Deploy the webhook to GKE and AKS

```shell
make install-webhook
```

```shell
make deploy-webhook-enabled
```

View Pod Configuration

```shell
KUBECONFIG=.kube/aws make show-pod
KUBECONFIG=.kube/gcp make show-pod
KUBECONFIG=.kube/azure make show-pod
```


```shell
KUBECONFIG=.kube/aws make list-buckets
KUBECONFIG=.kube/gcp make list-buckets
KUBECONFIG=.kube/azure make list-buckets
```

Cleanup

```shell
make delete-webhook-enabled uninstall-webhook
```
