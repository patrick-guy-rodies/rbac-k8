provider “azurerm” {
    # Azure Provider version (Optional)
    version = "=2.16.0"
  	features {}
    # Credentials are specified authenticating to Azure
    client_id = “${var.“CLIENTID”}“
    client_secret = “${var.“SECRET”}“
    tenant_id = “${var.“TENANTID”}“
    subscription_id = “${var.SUBID}“
}
    resource“azurerm_resource_group” “rg”{
        name = “${var.resource_group_name}“
        location = “${var.resource_group_location}“
    }
    resource“azurerm_kubernetes_cluster” “RBAC-TUTORIAL”{
        name = “${var.cluster_name}“
        location = “${var.resource_group_location}“
        resource_group_name = “${azurerm_resource_group.rg.name}“
        dns_prefix = “dns”
        agent_pool_profile {
            name = “agentpool”
            count = 3
            vm_size = “Standard_DS1_v2”
        }
        service_principal {
            # Specifying a Service Principal for AKS Cluster
            client_id = “${var.“CLIENTID”}“
            client_secret = “${var.“SECRET”}“
        }
        # Tag’s for AKS Cluster’s environment along with  nclustername
        tags = {
            environment = “development”
            cluster_name = “${var.cluster_name}“
        }
            # Enable Role Based Access Control
        role_based_access_control {
            enabled = true
        }
 }