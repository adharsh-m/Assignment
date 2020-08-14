variable "subscription_id" {
  description = "Enter Subscription ID for provisioning resources in Azure"
}
variable "client_id" {
  description = "Enter Client ID for Application created in Azure AD"
}

variable "client_secret" {
  description = "Enter Client secret for Application in Azure AD"
}

variable "tenant_id" {
  description = "Enter Tenant ID / Directory ID of your Azure AD. Run Get-AzureSubscription to know your Tenant ID"
}

variable "location" {
  description = "The default Azure region for the resource provisioning"
}

variable "resource_group_name" {
  description = "Resource group name that will contain various resources"
}

variable "vnet_cidr" {
  description = "CIDR block for Virtual Network"
}

variable "subnet_cidr" {
  description = "CIDR block for Subnet within a Virtual Network"
}


variable "vm_username" {
  description = "Enter admin username to SSH into Linux VM"
}

variable "pub_key" {
  description = "Enter admin password to SSH into VM"
}

variable "allowed_ssh_ips" {
  type        = list(string)
  description = "List of IPs to allow SSH Access"
}

variable "instance_count" {
  description = "Number of VM's to provision"
  default     = 2
}