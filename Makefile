NAME := oidc-discovery-demo

AWS_KUBECONFIG := .kube/aws
GCP_KUBECONFIG := .kube/gcp
AZURE_KUBECONFIG := .kube/azure

TOKEN ?= /var/run/secrets/tokens/sts-token

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

build-tools:
	$(MAKE) -C oidc-demo build-tools

fingerprint:
	oidc-demo/bin/fingerprint -server $(SERVER)

eks-fingerprint:
	$(MAKE) fingerprint SERVER=oidc.eks.eu-west-2.amazonaws.com

gke-fingerprint:
	$(MAKE) fingerprint SERVER=container.googleapis.com

aks-fingerprint:
	$(MAKE) fingerprint SERVER=oidc.prod-aks.azure.com

jwt-claims:
	oidc-demo/bin/claims \
		-jwt $$(kubectl exec $$(kubectl get po -l=app.kubernetes.io/name=oidc-discovery-demo -oname) -- cat $(TOKEN))

oidc-discovery:
	oidc-demo/bin/oidc-discovery \
		-jwt $$(kubectl exec $$(kubectl get po -l=app.kubernetes.io/name=oidc-discovery-demo -oname) -- cat $(TOKEN))

terraform-init:
	cd terraform && terraform init

terraform-plan: terraform-init
	cd terraform && terraform plan -var name=$(NAME)

terraform-%: terraform-init
	cd terraform && terraform $* -auto-approve -var name=$(NAME)

iam-role-arn:
	cd terraform && terraform output -raw aws_iam_role_arn

deploy-%:
	for i in $(AWS_KUBECONFIG) $(GCP_KUBECONFIG) $(AZURE_KUBECONFIG); do \
  		KUBECONFIG=$$i kubectl apply -k manifests/$*/; \
  	done

delete-%:
	for i in $(AWS_KUBECONFIG) $(GCP_KUBECONFIG) $(AZURE_KUBECONFIG); do \
  		KUBECONFIG=$$i kubectl delete -k manifests/$*/; \
  	done

list-buckets:
	kubectl exec $$(kubectl get po -l=app.kubernetes.io/name=$(NAME) -oname) -- aws s3 ls

show-pod:
	kubectl get po -l=app.kubernetes.io/name=$(NAME) -oyaml

install-webhook: export IMAGE=amazon/amazon-eks-pod-identity-webhook:latest
install-webhook:
	for i in $(GCP_KUBECONFIG) $(AZURE_KUBECONFIG); do \
		KUBECONFIG=$$i kubectl apply -f https://github.com/jetstack/cert-manager/releases/download/v1.7.0/cert-manager.yaml; \
		sleep 5; \
		KUBECONFIG=../$$i $(MAKE) -C aws-pod-identity-webhook cluster-up; \
	done

uninstall-webhook:
	for i in $(GCP_KUBECONFIG) $(AZURE_KUBECONFIG); do \
		KUBECONFIG=../$$i $(MAKE) -C aws-pod-identity-webhook cluster-down; \
		KUBECONFIG=$$i kubectl delete ns cert-manager; \
	done

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
	@echo "$(bold)Tools:$(reset)"
	@echo "  $(cyan)build-tools$(reset)            - Build the utility tools"
	@echo "  $(cyan)fingerprint$(reset)            - Get the Fingerprint for a server for AWS IAM OIDC Configuration: SERVER=x"
	@echo "  $(cyan)gke-fingerprint$(reset)        - Get the Fingerprint for the GCP Issuer"
	@echo "  $(cyan)eks-fingerprint$(reset)        - Get the Fingerprint for the AWS Issuer"
	@echo "  $(cyan)aks-fingerprint$(reset)        - Get the Fingerprint for the Azure Issuer"
	@echo "  $(cyan)jwt-claims$(reset)             - Retrieve the ServiceAccount Token and Display the Claims"
	@echo "  $(cyan)oidc-discovery$(reset)         - Retrieve the ServiceAccount Token and Display the Discovery Document and JWKs"
	@echo "$(bold)Terraform:$(reset)"
	@echo "  $(cyan)terraform-init$(reset)         - Run Terraform init"
	@echo "  $(cyan)terraform-plan$(reset)         - Run Terraform plan"
	@echo "  $(cyan)terraform-apply$(reset)        - Run Terraform apply"
	@echo "  $(cyan)terraform-destroy$(reset)      - Run Terraform destroy"
	@echo "  $(cyan)iam-role-arn$(reset)           - Display the AWS IAM Role ARN from the Terraform Output"
	@echo "$(bold)Kubernetes:$(reset)"
	@echo "  $(cyan)deploy-manual$(reset)          - Deploy resources with manual configuration"
	@echo "  $(cyan)delete-manual$(reset)          - Delete resources with manual configuration"
	@echo "  $(cyan)deploy-webhook-enabled$(reset) - Deploy resources with webhook managed configuration"
	@echo "  $(cyan)delete-webhook-enabled$(reset) - Delete resources with webhook managed configuration"
	@echo "  $(cyan)list-buckets$(reset)           - List S3 buckets from within deployed pod"
	@echo "  $(cyan)show-pod$(reset)               - Display the Pods YAML"
	@echo "$(bold)AWS Pod Identity Webhook:$(reset)"
	@echo "  $(cyan)install-webhook$(reset)        - Install the AWS Pod Identity Webhook"
	@echo "  $(cyan)uninstall-webhook$(reset)      - Uninstall the AWS Pod Identity Webhook"
