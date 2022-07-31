
REGION=westeurope
SUBSCRIPTION_ID=$(shell jq .provider.azurerm.subscription_id terraform/provider.tf.json -r)
RESOURCE_GROUP_NAME=$(shell jq .terraform.backend.azurerm.resource_group_name terraform/terraform.tf.json -r)
STORAGE_ACCOUNT_NAME=$(shell jq .terraform.backend.azurerm.storage_account_name terraform/terraform.tf.json -r)
CONTAINER_NAME=$(shell jq .terraform.backend.azurerm.container_name terraform/terraform.tf.json -r)

.PHONY: terraform

terraform:
	opta generate-terraform --directory terraform --backend=remote --auto-approve --readme-format=md

state-store:
	az account set --subscription $(SUBSCRIPTION_ID)
	az group create --name $(RESOURCE_GROUP_NAME) --location $(REGION) 
	az storage account create --resource-group $(RESOURCE_GROUP_NAME) --name $(STORAGE_ACCOUNT_NAME) --sku Standard_LRS --encryption-services blob 
	az storage container create --name $(CONTAINER_NAME) --account-name $(STORAGE_ACCOUNT_NAME) 

key:
	@echo export ARM_ACCESS_KEY=$(shell az storage account keys list --resource-group $(RESOURCE_GROUP_NAME) --account-name $(STORAGE_ACCOUNT_NAME) --query '[0].value' -o tsv)

clean:
	rm -rf terraform
	rm -f main.tf.json
	rm -f opta_crash_report.zip

purge:
	az group delete --resource-group $(RESOURCE_GROUP_NAME) --subscription $(SUBSCRIPTION_ID) --no-wait

