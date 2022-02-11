NAME ?= oidc-discovery-demo

eks-create: export KUBECONFIG=../.kube/aws
eks-create:
	eksctl create cluster --name $(NAME) --region eu-west-2

eks-delete: export KUBECONFIG=../.kube/aws
eks-delete:
	eksctl delete cluster --name $(NAME)

gke-create: export KUBECONFIG=../.kube/gcp
gke-create:
	gcloud container clusters create $(NAME) --region europe-west2 --quiet

gke-delete: export KUBECONFIG=../.kube/gcp
gke-delete:
	gcloud container clusters delete $(NAME) --region europe-west2 --quiet

aks-enable:
	az feature register --name EnableOIDCIssuerPreview --namespace Microsoft.ContainerService
	az provider register -n Microsoft.ContainerService
	az extension add --name aks-preview
	az extension update --name aks-preview

aks-create: export KUBECONFIG=../.kube/azure
aks-create: aks-enable
	az group create -n $(NAME) -l westeurope --only-show-errors
	az aks create -n $(NAME) -g $(NAME) --enable-oidc-issuer --only-show-errors -y
	az aks get-credentials -n $(NAME) -g $(NAME) -f ../.kube/azure

aks-delete: export KUBECONFIG=../.kube/azure
aks-delete:
	az aks delete -n $(NAME) -g $(NAME) --only-show-errors -y
	az group delete -n $(NAME) --only-show-errors -y
