provider "azurerm" {
  subscription_id = var.subscription_id
  client_id       = var.client_id
  client_secret   = var.client_secret
  tenant_id       = var.tenant_id
}

resource "azurerm_resource_group" "terraform_rg" {
  name      = var.resource_group_name
  location  = var.location
}

resource "azurerm_virtual_network" "test_vnet" {
  name                  = "Trbhi-Terraform-VNet"
  address_space         = ["${var.vnet_cidr}"]
  location              = var.location
  resource_group_name   = azurerm_resource_group.terraform_rg.name

  tags = {
    group = var.resource_group_name
  }
}

resource "azurerm_subnet" "test_subnet" {
  name                    = "Trbhi-Terraform-Subnet"
  address_prefix          = var.subnet_cidr
  virtual_network_name    = azurerm_virtual_network.test_vnet.name
  resource_group_name     = azurerm_resource_group.terraform_rg.name
}

resource "azurerm_network_security_group" "terraform_nsg" {
  name                = "Trbhi-Terraform-NSG"
  location            = var.location
  resource_group_name = azurerm_resource_group.terraform_rg.name
  tags = {
    group = var.resource_group_name
  }
}

resource "azurerm_network_security_rule" "ssh_rule" {
  name                        = "AllowSSH"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "22"
  source_address_prefix       = var.allowed_ssh_ips
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.terraform_rg.name
  network_security_group_name = azurerm_network_security_group.terraform_nsg.name
}

resource "azurerm_network_security_rule" "ssh_rule" {
  name                                        = "AllowFromSelf"
  priority                                    = 100
  direction                                   = "Inbound"
  access                                      = "Allow"
  protocol                                    = "Tcp"
  source_port_range                           = "*"
  destination_port_range                      = "*"
  destination_application_security_group_ids  = ["${azurerm_network_security_group.terraform_nsg.name}"]
  resource_group_name                         = azurerm_resource_group.terraform_rg.name
  network_security_group_name                 = azurerm_network_security_group.terraform_nsg.name
}

resource "azurerm_public_ip" "test_pub_ip" {
  count                           = var.instance_count
  name                            = "Trbhi-Terraform-PIP-${count.index}"
  location                        = ${var.location}
  resource_group_name             = ${azurerm_resource_group.terraform_rg.name}
  public_ip_address_allocation    = "static"

  tags = {
    group = var.resource_group_name
  }
}

resource "azurerm_network_interface" "public_nic" {
  count                     = var.instance_count
  name                      = "Trbhi-Terraform-NIC-${count.index}"
  location                  = var.location
  resource_group_name       = azurerm_resource_group.terraform_rg.name
  network_security_group_id = azurerm_network_security_group.terraform_nsg.id

  ip_configuration {
    name                            = "Trbhi-Terraform-NicConfig"
    subnet_id                       = azurerm_subnet.test_subnet.id
    private_ip_address_allocation   = "dynamic"
    public_ip_address_id            = element(azurerm_public_ip.test_pub_ip.*.id, count.index}
  }
  tags = {
    group = var.resource_group_name
  }
}

resource "azurerm_virtual_machine" "Test_Terraform_Instance" {
  count                 = var.instance_count
  name                  = "Trbhi-Terraform-Instance-${count.index}"
  location              = var.location
  resource_group_name   = azurerm_resource_group.terraform_rg.name
  network_interface_ids = [element(azurerm_network_interface.public_nic.*.id, count.index)]
  vm_size               = "Standard_B1ls"

#This will delete the OS disk automatically when deleting the VM
  delete_os_disk_on_termination = true
  delete_data_disks_on_termination = true

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }

  storage_os_disk {
    name              = "osdisk-${count.index}"
    managed_disk_type = "Standard_LRS"
    caching           = "ReadWrite"
    create_option     = "FromImage"
  }

  os_profile {
    computer_name  = "ubuntu"
    admin_username = var.vm_username
  }

  os_profile_linux_config {
        disable_password_authentication = true
        ssh_keys {
            path     = "/home/${var.vm_username}/.ssh/authorized_keys"
            key_data = var.pub_key
        }
    }

  tags = {
    group = var.resource_group_name
  }
}