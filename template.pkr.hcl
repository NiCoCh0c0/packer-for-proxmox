# autre inspi : https://github.com/pebcakerror/homelab/blob/main/packer/proxmox/ubuntu-server-2204/ubuntu-server-jammy.pkr.hcl

packer {
  required_plugins {
    proxmox = {
      version = ">= 1.1.1"
      source  = "github.com/hashicorp/proxmox"
    }
  }
}

variable "proxmox_username" {
  type = string
}
variable "proxmox_password" {
  type = string
  sensitive = true
}

source "proxmox-iso" "proxmox-template" {
    # Insert the boot iso
    boot_iso {
        # Set the iso on ide0 cdrom
        type = "ide"
        index = 0
        # Set the iso file to use
        iso_url          = "https://releases.ubuntu.com/22.04.1/ubuntu-22.04.1-live-server-amd64.iso"
        iso_checksum     = "sha256:10f19c5b2b8d6db711582e0e27f5116296c34fe4b313ba45f9b201a5007056cb"
        iso_storage_pool = "local"
        # emove the mounted ISO from the template after finishing
        unmount = true
    }

    # Proxmox node connection information
    proxmox_url              = "https://192.168.X.X:8006/api2/json"
    insecure_skip_tls_verify = true
    username                 = var.proxmox_username
    password                 = var.proxmox_password
    node                     = "autopve"
    task_timeout             = "50m"

    # VM configuration
    memory = 2048
    cores  = 4
    cpu_type = "host"
    os     = "l26"
    # Network configuration
    network_adapters {
        model  = "virtio"
        bridge = "vmbr0"
    }
    # Disk configuration
    disks {
        type              = "scsi"
        disk_size         = "10G"
        storage_pool      = "local-lvm"
        storage_pool_type = "lvm"
    }
    qemu_agent = true
    disable_kvm = true # TO DELETE IF ON CLASSIC PROXMOX INSTALLATION

    # SSH configuration to connect to the VM after installation
    ssh_username = "ubuntu"
    ssh_password = "ubuntu"
    ssh_timeout = "50m"

    boot_command = [
        "<esc><wait>",
        "e<wait>",
        "<down><down><down><end>",
        "<bs><bs><bs><bs><wait>",
        "autoinstall ds=nocloud-net\\;s=http://{{ .HTTPIP }}:{{ .HTTPPort }}/ ---<wait>",
        "<f10><wait>"
    ]

    # Configure how to deliver ther installation cloud-init data
    http_directory = "www"
    http_port_min = 8001
    http_port_max = 8001
}

build {
    name = "ubuntu-x86_64"
    sources = [
        "source.proxmox-iso.proxmox-template",
    ]

    # Clean up the machine for cloud-init
    provisioner "shell" {
        execute_command = "echo 'ubuntu' | {{ .Vars }} sudo -S -E sh -eux '{{ .Path }}'"
        inline = [
        "while [ ! -f /var/lib/cloud/instance/boot-finished ]; do echo 'Waiting for cloud-init...'; sleep 1; done",
        "sudo rm /etc/ssh/ssh_host_*",
        "sudo truncate -s 0 /etc/machine-id",
        "sudo apt -y autoremove --purge",
        "sudo apt -y clean",
        "sudo apt -y autoclean",
        "sudo cloud-init clean",
        "sudo rm -f /etc/cloud/cloud.cfg.d/subiquity-disable-cloudinit-networking.cfg",
        "sudo sync"
        ]
    }
}