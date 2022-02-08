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

help:
	@echo "$(bold)Usage:$(reset) make $(cyan)<target>$(reset)"
	@echo
	@echo "$(bold)Clusters:$(reset)"
	@echo "  $(cyan)clusters-create$(reset)        - Create the EKS, GKE and AKS Clusters"
	@echo "  $(cyan)clusters-delete$(reset)        - Delete the EKS, GKE and AKS Clusters"