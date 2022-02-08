NAME := oidc-discovery-demo

AWS_KUBECONFIG := .kube/aws
GCP_KUBECONFIG := .kube/gcp
AZURE_KUBECONFIG := .kube/azure

cyan := $(shell which tput > /dev/null && tput setaf 6 2>/dev/null || echo "")
reset := $(shell which tput > /dev/null && tput sgr0 2>/dev/null || echo "")
bold  := $(shell which tput > /dev/null && tput bold 2>/dev/null || echo "")

clusters-%:
	-$(MAKE) -C clusters eks-$* NAME=$(NAME)
	-$(MAKE) -C clusters gke-$* NAME=$(NAME)
	-$(MAKE) -C clusters aks-$* NAME=$(NAME)

eks-issuer: export KUBECONFIG=$(AWS_KUBECONFIG)
eks-issuer:
	eksctl get cluster -n oidc-discovery-demo -o json | jq -r .[0].Identity.Oidc.Issuer

gke-issuer: export KUBECONFIG=$(GCP_KUBECONFIG)
gke-issuer:
	gcloud container clusters describe oidc-discovery-demo --region europe-west2 --format="json" | jq -r .selfLink

aks-issuer: export KUBECONFIG=$(AZURE_KUBECONFIG)
aks-issuer:
	az aks show -n oidc-discovery-demo -g oidc-discovery-demo --only-show-errors | jq -r .oidcIssuerProfile.issuerUrl

help:
	@echo "$(bold)Usage:$(reset) make $(cyan)<target>$(reset)"
	@echo
	@echo "$(bold)Clusters:$(reset)"
	@echo "  $(cyan)clusters-create$(reset)        - Create the EKS, GKE and AKS Clusters"
	@echo "  $(cyan)clusters-delete$(reset)        - Delete the EKS, GKE and AKS Clusters"
	@echo "$(bold)Issuers:$(reset)"
	@echo "  $(cyan)eks-issuer$(reset)             - Get the AWS Issuer URL"
	@echo "  $(cyan)gke-issuer$(reset)             - Get the GCP Issuer URL"
	@echo "  $(cyan)aks-issuer$(reset)             - Get the Azure Issuer URL"
