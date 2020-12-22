variable "CLIENTID" {
    description = "contains the Client Id for service principal"
    type = string
}

variable "SECRET" {
    description = "contains the Client Secret for service principal"
    type = string
}

variable "TENANTID" {
    description = "contains the Tenant Id for service principal"
    type = string
}

variable "SUBID" {
    description = "contains the Subscription Id for service principal"
    type = string
}

variable "resource_group_name" {
    description = "contains the name of the Resource Group"
    default = "rgpazewsmlit-sandbox-pgr095-001"
}

variable "resource_group_location" {
    description = "contains the location Resource Group of cluster"
    default = "westeurope"
}

variable "cluster_name" {
    description = "contains AKS Cluster Name"
    default = "RBAC-TUTORIAL"
}