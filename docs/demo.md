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
