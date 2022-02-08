# OIDC Discovery Demo

This demo utilises the OIDC Discovery Feature in combination with AWS Federated Identity to grant read access to
S3 to containers running in EKS, GKE and AKS.

## Create the clusters

```shell
make clusters-create
```

Create an EKS, GKE and AKS cluster, kubeconfig files are stored in the [.kube](../.kube) directory.

At the time of writing the OIDC Issuer feature is in preview and needs to be specifically enabled.
