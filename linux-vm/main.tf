
# we assume that this Custom Image already exists

### Data Sources ###

data "azurerm_image" "custom" {
  name_regex          = "${var.custom_image_name}"
  sort_descending     = true
  resource_group_name = "${var.custom_image_resource_group_name}"
}

terraform {
  backend "azurerm" {}
}

resource "azurerm_network_interface" "nic" {
  count               = "${var.server_count}"
  name                = "${var.rg_prefix}${var.hostname[count.index % length(var.hostname)]}nic"
  location            = "${var.location}"
  resource_group_name = "${var.resource_group}"

  ip_configuration {
    name                          = "${var.rg_prefix}${var.hostname[count.index % length(var.hostname)]}ipconfig"
    subnet_id                     = "${var.ncr_subnet}"
    private_ip_address_allocation = "Dynamic"

  }
}

resource "azurerm_virtual_machine" "vm" {
  count                 = "${var.server_count}"
  name                  = "${var.rg_prefix}-${var.hostname[count.index % length(var.hostname)]}"
  location              = "${var.location}"
  resource_group_name   = "${var.resource_group}"
  vm_size               = "${var.vm_size}"
  network_interface_ids = ["${element(azurerm_network_interface.nic.*.id, count.index)}"]

  # Uncomment this line to delete the OS disk automatically when deleting the VM
   delete_os_disk_on_termination = true


  # Uncomment this line to delete the data disks automatically when deleting the VM
   #delete_data_disks_on_termination = true

  storage_image_reference {
    id = "${data.azurerm_image.custom.id}"
  }

  storage_os_disk {
    name              = "${var.rg_prefix}-${var.hostname[count.index % length(var.hostname)]}-osdisk"
    managed_disk_type = "Standard_LRS"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    disk_size_gb      = "${var.disk_size_gb}"
  }

  os_profile {
    computer_name  = "${var.rg_prefix}-${var.hostname[count.index % length(var.hostname)]}"
    admin_username = "${var.admin_username}"
    admin_password = "${var.admin_password}"
  }

  os_profile_linux_config  {
   disable_password_authentication = false
  }

tags = "${var.tags}"
}


