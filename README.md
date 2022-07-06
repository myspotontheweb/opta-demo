# opta-demo

This is a demo of the [opta tool](https://www.opta.dev/), used with Azure.
The experiment did not initially work, so decided to concentrate on running the generated Terraform instead.

# Software

Need the following tools installed

* az (Azure CLI)
* opta
* terraform
* jq
* yq

# Usage

Edit the [opta.yaml](opta.yaml#L7-L8) file an fill in the Azure Tenant + Subscription IDs. The following command can help obtain these settings

    $ az account list | jq '.[]|select(.name=="<subscription name>")|{"subscription_id":.id,"tenant_id":.tenantId}'
    {
      "subscription_id": "XXXX-XXXX-XXXX-XXXX-XXXX",
      "tenant_id": "YYYY-YYYY-YYYY-YYYY-YYYY"
    }

Generate the Terraform code and create the remote backend (using an Azure storage account)

    make terraform state-store
    
Use make to retrieve the access key that is required by terraform

    $ make key
    export ARM_ACCESS_KEY=XXXXXXXXXXXXXXXXXXXXXXXXXX
    
Run terraform as follows:

    cd terraform

    export ARM_ACCESS_KEY=XXXXXXXXXXXXXXXXXXXXXXXXXX
    terraform init
    
    terraform plan -compact-warnings -lock=false -input=false -out=tf.plan -target=module.base
    terraform apply -compact-warnings -auto-approve tf.plan
    
    terraform plan -compact-warnings -lock=false -input=false -out=tf.plan -target=module.k8scluster
    terraform apply -compact-warnings -auto-approve tf.plan
    
    terraform plan -compact-warnings -lock=false -input=false -out=tf.plan -target=module.k8sbase
    terraform apply -compact-warnings -auto-approve tf.plan
    
# Cleanup

Delete resources using Terraform

    terraform plan -compact-warnings -lock=false -input=false -out=tf.plan -target=module.base -target=module.k8scluster -target=module.k8sbase -destroy
    terraform apply -compact-warnings -auto-approve tf.plan
    
Cleanup file system

    make clean
    
Purge Terraform state store (and Azure resource group)

    make purge
