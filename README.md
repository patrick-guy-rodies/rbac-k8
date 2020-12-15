![Azure](https://assets.cloud.im/prod/ux1/images/logos/azure/azure-2x.png)

Remote backend with Azure Storage Account and RBAC.
    
# Initialise Deployment for Infrastructure for implementing a cluster with default values

This repo contains all the code required to deploy & configure a AKS cluster latest version
This is using service principal for application and storage for keeping terraform state

## Key features

* AKS cluster of three nodes in Northern Region
* Linux OS with 30 gb disk


## Possible Improvements or Security issue

* Security key not encrypted, will need to use Vault 
* Disaster Recovery
* MakeFile

## Pre-requisites

1. terraform

1. az (Azure CLI)

1. kubectl

1. Storage setup using tstate

## References

https://www.mikaelkrief.com/terraform-remote-backend-azure/
https://medium.com/@chrisedrego/deep-dive-with-provisioning-aks-rbac-enabled-kubernetes-cluster-using-terraform-895587ddc027

>
## Precaution
When deploying any resources, you can risk to recreate or delete any resources. Please consult this excellent blog around this process. [Reference] (https://coderbook.com/@marcus/prevent-terraform-from-recreating-or-deleting-resource/)


For example using such code can protect any stateful resource:

```json

resource "azure_vm" "db" {
    lifecycle {
            prevent_destroy = true
    }
}

```

### Deploying

1. Clone the [patrickguyrodies/k8cluster](bitbucket.org:patrickguyrodies/k8cluster.git) repo and cd into the root of the repo.

1. Initialise state and Import stateful resources
    
    As some resources (subscription, service principal, storage) will be created manually and kept out of scope for this example, we will remove them from Terraform state declaration. We are also using Terraform r

                $ terraform init -backend-config="storage_account_name=storagepgr095" -backend-config="container_name=tfstate" -backend-config="access_key=A3DK/CM7WO/+N5pmCNDYUwSheaUfcdViSEXG+VgAgxsWnrj5Z3uywEchHRRaPi+9JWzDs7Vxxy6aCEZDv+T1Xw==" -backend-config="key=codelab.microsoft.tfstate"

    1. Import resource group

                $ terraform import azurerm_resource_group.staticevent /subscriptions/a4fe28da-0262-4b49-a9ea-7f2bba03f85b/resourceGroups/rgpazewsmlit-sandbox-pgr095-001

                $ terraform import azurerm_resource_group.example /subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/group1

                $ terraform import azurerm_log_analytics_workspace.test /subscriptions/a4fe28da-0262-4b49-a9ea-7f2bba03f85b/resourcegroups/rgpazewsmlit-sandbox-pgr095-001/providers/microsoft.operationalinsights/workspaces/testloganalyticsworkspacename

1. Create clusters
    1. Export your service principal credentials


                $ export TF_VAR_client_id=<your-client-id>
                $ export TF_VAR_client_secret=<your-client-secret> 
        
        Export your service principal credentials (Keybase sandbox resourcegroup txt file for Patrick example). Replace the <your-client-id> and <your-client-secret> placeholders with the appId and password values associated with your sandbox credential.

    1. Run Terraform plan

                $ terraform plan -out out.plan

    1. Apply plan

        Run the terraform apply command to apply the plan to create the Kubernetes cluster. The process to create a Kubernetes cluster can take several minutes, resulting in the Cloud Shell session timing out. If the Cloud Shell session times out, you can follow the steps in the section "Recover from a Cloud Shell timeout" to enable you to complete the tutorial.

                $ terraform apply out.plan

    1. Browse your new cluster

        1. UI using az cli

                $ az aks browse --name <cluster name> --resource-group <resource group name for cluster>

        1. UI using kubectl proxy
            The UI is not installed by default, please check https://kubernetes.io/docs/tasks/access-application-cluster/web-ui-dashboard/

                $ az aks get-credentials --resource-group rgpazewsmlit-sandbox-pgr095-001 --name cstaticevent
                
            Output will be saved in ~/.kube/config

                $ kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/v2.0.0/aio/deploy/recommended.yaml

                $ kubectl proxy

            You can use http://localhost:8001/api/v1/namespaces/kubernetes-dashboard/services/https:kubernetes-dashboard:/proxy/#/overview?namespace=default to go to your cluster. The login can use the default config file on ~/.kube/config

        1. UI using third party tool such as Octant

            Follow instructions: https://github.com/vmware-tanzu/octant

## Destroying cluster

                $ terraform plan -destroy -out destroy.plan


                $ terraform apply destroy.plan

