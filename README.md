![Azure](https://assets.cloud.im/prod/ux1/images/logos/azure/azure-2x.png)

Remote backend with Azure Storage Account and RBAC.
    
# Initialise Deployment for Infrastructure for implementing a cluster with default values

This repo contains all the code required to deploy & configure a AKS cluster latest version
This is using service principal for application, RBAC  and storage for keeping terraform state

## Key features

* AKS cluster of three nodes in Northern Region
* Linux OS with 100 gb disk
* RBAC


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

1. https://www.mikaelkrief.com/terraform-remote-backend-azure/

1. https://medium.com/@chrisedrego/deep-dive-with-provisioning-aks-rbac-enabled-kubernetes-cluster-using-terraform-895587ddc027


## Precaution
> When deploying any resources, you can risk to recreate or delete any resources. Please consult this excellent blog around this process: [Reference](https://coderbook.com/@marcus/prevent-terraform-from-recreating-or-deleting-resource/)


For example using such code can protect any stateful resource:

``` json

resource "azure_vm" "db" {
    lifecycle {
            prevent_destroy = true
    }
}

```

### Deploying

1. Clone the [patrick-guy-rodies/rbac-k8](https://github.com/patrick-guy-rodies/rbac-k8.git) repo and cd into the root of the repo.

1. Export service principal key as environment variable

``` bash

$ cat  export SUBID="XXXXXXXXXXXXX" >> ~/.zshenv
$ cat  export CLIENTID="XXXXXXXXXXXXX" >> ~/.zshenv
$ cat  export TENANTID="XXXXXXXXXXXXX" >> ~/.zshenv        
$ source ~/.zshenv

```
1. Explaining three files needed to create your cluster

    1. main.tf
        
        As we already know, that terraform can be used to provision cloud resources on multiple cloud providers such as AWS, Azure, GCP, Heroku. a provider is responsible for understanding API interactions and exposing resources. The provider comes into the picture at the very initial phase while interacting with the Cloud Provider (Azure), as you can call it as an entry point to decide which cloud provider would we be provisioning the resources. To understand more about the various cloud providers that terraform has to offer to refer to the official link
        
        In this block, we watch carefully we are specifying the Azure (arurerm) Azure Resource Manager provider along with the credentials from the Service Principal to authenticate to Azure. The version can be found using command line:

        ``` bash
        
        $ az --version

        azure-cli                         2.16.0

        core                              2.16.0
        telemetry                          1.0.6

        Extensions:
        aks-preview                       0.4.70

        Python location '/usr/local/Cellar/azure-cli/2.16.0/libexec/bin/python'
        Extensions directory '/Users/xxxxxxxx/.azure/cliextensions'

        Python (Darwin) 3.8.6 (default, Nov 20 2020, 23:57:10)
        [Clang 12.0.0 (clang-1200.0.32.27)]

        Legal docs and information: aka.ms/AzureCliLegal


        Your CLI is up-to-date.

        Please let us know how we are doing: https://aka.ms/azureclihats
        and let us know if you're interested in trying out our newest features: https://aka.ms/CLIUXstudy

        ```


    1. variables.tf

        Many of the values in the main.tf were not hardcoded, rather all of them refer to var followed by the name of the variables all of these variables are specified in these variables.tf.
        > Please make note that its not recommended approach to store secrets/credentials in plain text variables.tf file, you should store these variables in environment variables if in case of CI/CD environment as the secret to avoid exposure and thereby hampering the security.
        TF_VAR_name as explained in https://www.terraform.io/docs/commands/environment-variables.html, please refer to Export service principal item above.

1. Terraform Stages

    1. Terraform init

        init is used to initialize the current module or folder which contains the main.tf. If there is any cloud provider block defined inside main.tf in the current directory where terraform init command is run, it goes ahead and downloads the binary needed in order to communicate with APIs of the specific cloud provider.

        ``` bash

        $ terraform init

        Initializing the backend...

        Initializing provider plugins...
        - Checking for available provider plugins...
        - Downloading plugin for provider "azurerm" (hashicorp/azurerm) 2.16.0...

        Terraform has been successfully initialized!

        You may now begin working with Terraform. Try running "terraform plan" to see
        any changes that are required for your infrastructure. All Terraform commands
        should now work.

        If you ever set or change modules or backend configuration for Terraform,
        rerun this command to reinitialize your working directory. If you forget, other
        commands will detect it and remind you to do so if necessary.

        ```
        After initialising the folder, we will need to create some resource manually to keep them out of scope, we will remove them from Terraform state declaration.
        In the import below we are using rbac-tutorial name for main.tf.

        ``` bash

        $ terraform import azurerm_resource_group.rbac-tutorial /subscriptions/a4fe28da-0262-4b49-a9ea-7f2bba03f85b/resourceGroups/rgpazewsmlit-sandbox-pgr095-001
        azurerm_resource_group.rbac-tutorial: Importing from ID "/subscriptions/a4fe28da-0262-4b49-a9ea-7f2bba03f85b/resourceGroups/rgpazewsmlit-sandbox-pgr095-001"...
        azurerm_resource_group.rbac-tutorial: Import prepared!
        Prepared azurerm_resource_group for import
        azurerm_resource_group.rbac-tutorial: Refreshing state... [id=/subscriptions/a4fe28da-0262-4b49-a9ea-7f2bba03f85b/resourceGroups/rgpazewsmlit-sandbox-pgr095-001]

        Import successful!

        The resources that were imported are shown above. These resources are now in
        your Terraform state and will henceforth be managed by Terraform.

        ```
    
    1. Terraform plan

        ``` bash
        
        $ terraform plan -out out.plan

        ```
        Check the output for + create or ~ update in-place signs to make sure that correct resources will be created, updated or deleted

    1. Apply plan

        Run the terraform apply command to apply the plan to create the Kubernetes cluster. The process to create a Kubernetes cluster can take several minutes, resulting in the Cloud Shell session timing out. If the Cloud Shell session times out, you can follow the steps in the section "Recover from a Cloud Shell timeout" to enable you to complete the tutorial.
        
        ``` bash

        $ terraform apply out.plan
        terraform apply out.plan                                                                                                                          

        azurerm_resource_group.rbac-tutorial: Modifying... [id=/subscriptions/a4fe28da-0262-4b49-a9ea-7f2bba03f85b/resourceGroups/rgpazewsmlit-sandbox-pgr095-001]
        azurerm_kubernetes_cluster.rbac-tutorial: Creating...
        azurerm_resource_group.rbac-tutorial: Modifications complete after 1s [id=/subscriptions/a4fe28da-0262-4b49-a9ea-7f2bba03f85b/resourceGroups/rgpazewsmlit-sandbox-pgr095-001]
        azurerm_kubernetes_cluster.rbac-tutorial: Still creating... [4m0s elapsed]
        azurerm_kubernetes_cluster.rbac-tutorial: Creation complete after 4m7s [id=/subscriptions/a4fe28da-0262-4b49-a9ea-7f2bba03f85b/resourcegroups/rgpazewsmlit-sandbox-pgr095-001/providers/Microsoft.ContainerService/managedClusters/RBAC-TUTORIAL]

        Apply complete! Resources: 1 added, 1 changed, 0 destroyed.

        The state of your infrastructure has been saved to the path
        below. This state is required to modify and destroy your
        infrastructure, so keep it safe. To inspect the complete state
        use the `terraform show` command.

        State path: terraform.tfstate
        ```

    1. Browse your new cluster

        1. UI using az cli
             ``` bash

            $ az aks browse --name <cluster name> --resource-group <resource group name for cluster>

             ```

        1. UI using kubectl proxy
            The UI is not installed by default, please check https://kubernetes.io/docs/tasks/access-application-cluster/web-ui-dashboard/

             ``` bash

            $ az aks get-credentials --subscription a4fe28da-0262-4b49-a9ea-7f2bba03f85b --resource-group rgpazewsmlit-sandbox-pgr095-001 --name RBAC-K8

            The behavior of this command has been altered by the following extension: aks-preview
            Merged "RBAC-TUTORIAL" as current context in /Users/patrickrodies/.kube/config
                
            Output will be saved in ~/.kube/config

            $ kubectl apply -f kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/v2.1.0/aio/deploy/recommended.yaml

            $ kubectl proxy

            You can use http://localhost:8001/api/v1/namespaces/kubernetes-dashboard/services/https:kubernetes-dashboard:/proxy/#/overview?namespace=default to go to your cluster. The login can use the default config file on ~/.kube/config
             
            ```

        1. UI using third party tool such as Octant

            Follow instructions: https://github.com/vmware-tanzu/octant
    
1. Start and Stop your cluster to reduce cost

    Please check [patrick-guy-rodies/start-stop-aks](https://github.com/patrick-guy-rodies/start-stop-aks)

    ``` bash

        $ ~/Applications/start-stop-aks stop RBAC-TUTORIAL #use start, stop or show as command

    ```
1. Using Waypoint to Build, Deploy and Release artifacts

    Please check [patrick-guy-rodies/waypoint-AKS](https://github.com/patrick-guy-rodies/waypoint-AKS)

1. Prometheus

    1. Metrics server: kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml
    1. Helm installation for Prometheus
        1. helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
        1. helm repo add stable https://charts.helm.sh/stable
        1. helm repo update
        1. helm -n monitoring install v2.23 prometheus-community/kube-prometheus-stack

## Destroying cluster

                $ terraform plan -destroy -out destroy.plan


                $ terraform apply destroy.plan