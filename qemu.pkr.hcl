packer {
  required_plugins {
    qemu = {
      source  = "github.com/hashicorp/qemu"
      version = "~> 1"
    }
  }
}

variable username {
  type    = string
  default = env("USER")
}

source qemu ubuntu-server {
  // --- Distribution ---
  iso_url      = "https://releases.ubuntu.com/22.04/ubuntu-22.04.5-live-server-amd64.iso"
  iso_checksum = "sha256:9bc6028870aef3f74f4e16b900008179e78b130e6b0b9a140635434a46aa98b0"

  // --- Hardware Configuration ---
  machine_type   = "q35"
  accelerator    = "kvm"
  disk_size      = "20G"
  disk_interface = "virtio"
  net_device     = "virtio-net"
  cpus           = 2
  memory         = 2048 // MiB
  qemuargs = [
    ["-nodefaults"],
    ["-no-user-config"],
    ["-cpu", "host"],
    ["-vga", "virtio"],
  ]

  // --- Connection ---
  headless             = false
  ssh_username         = var.username
  ssh_private_key_file = "ssh/user-key"
  ssh_timeout          = "20m" // Allow time for installation

  // --- Installation ---
  cd_label = "cidata"
  cd_content = {
    "meta-data" = "instance-id: ubuntu-server",
    "user-data" = templatefile("cloud-init/user-data", {
      username           = var.username,
      ssh_authorized_key = file("ssh/user-key.pub")
    })
  }
  boot_wait         = "4s"
  boot_key_interval = "20ms"
  # This sequence adds 'autoinstall' to the kernel command line
  boot_command = [
    "e",                       # Presses 'e' to edit the boot entry
    "<down><down><down>",      # Navigates to the kernel line
    "<end>",                   # Moves cursor to the end of the line
    " autoinstall ds=nocloud", # Appends the required parameters
    "<f10>"                    # Boots with the new parameters
  ]
  shutdown_timeout = "5s"

  // --- Output ---
  output_directory = "images"
  vm_name          = "ubuntu-server"
}

build {
  sources = ["source.qemu.ubuntu-server"]
}
