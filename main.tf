provider "azurerm" {
    # Azure Provider version (Optional)
    version = "=2.16.0"
  	features {}
        # Credentials are specified authenticating to Azure
        client_id = var.CLIENTID
        client_secret = var.SECRET
        tenant_id = var.TENANTID
        subscription_id = var.SUBID
}
#using data to ref existing resourcegroup, to create it you will need to use resource
data "azurerm_resource_group" "rbac-tutorial" {
    name     = var.resource_group_name
}
resource "azurerm_resource_group" "rbac-tutorial" {
  # (resource arguments)
  name     = var.resource_group_name
  location = var.resource_group_location
}
resource "azurerm_kubernetes_cluster" "rbac-tutorial"{
    name = var.cluster_name
    location = var.resource_group_location
    resource_group_name   = var.resource_group_name
    dns_prefix = "dns"
    
    default_node_pool {
        name            = "agentpool"
        vm_size         = "Standard_DS2_v2"
        node_count      = 3
        os_disk_size_gb = 30
    }
    service_principal {
        # Specifying a Service Principal for AKS Cluster
        client_id = var.CLIENTID
        client_secret = var.SECRET
    }
    # Tags for AKS Clusters environment along with clustername
    tags = {
        environment = "development"
    }
    # Enable Role Based Access Control
    role_based_access_control {
        enabled = true
    }
}