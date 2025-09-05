terraform {
  required_providers {
    kubernetes = {
      source = "hashicorp/kubernetes"
    }
  }
}

provider "kubernetes" {
  config_path    = var.kube_config
  config_context = var.kube_context
}

module "kickstart_template" {
  source = "../../tf-modules/kickstart-template"
  architecture = var.architecture
  builder_prefix = var.builder_prefix
  container_registry = var.container_registry
  cores = var.cores
  disk_size = var.disk_size
  kernel_args = var.kernel_args
  kernel_boot_container = var.kernel_boot_container
  kickstart_file = var.kickstart_file
  memory = var.memory
  secure_boot = var.secure_boot
  sockets = var.sockets
  storage_class = var.storage_class
  storage_class_volume_mode = var.storage_class_volume_mode
  threads = var.threads
  vm_create_timeout = var.vm_create_timeout
  vm_delete_timeout = var.vm_delete_timeout
  vm_update_timeout = var.vm_update_timeout
  volume_label = var.volume_label
}

variable "kube_config" {
  default = "~/.kube/config"
}

variable "kube_context" {
  default = "default"
}

variable "architecture" {
  default = "amd64"
  description = "Hardware architecture."
  type = string
}

variable "builder_prefix" {
  default = "vm-template"
  description = "Prefix name for the namespace."
  type = string
}

variable "container_registry" {
  default = "hub.docker.io"
  description = "Container registry for the container."
  type = string
}

variable "cores" {
  default = 4
  description = "Cores per CPU."
  type = number
}

variable "disk_size" {
  default = "8Gi"
  description = "Volume size to create."
  type = string
}

variable "kernel_args" {
  default = "inst.noverifyssl inst.geoloc=0 vga=795 fips=1 hostname=centos-stream10-gold inst.repo=https://mirrors.mit.edu/centos-stream/10-stream/BaseOS/x86_64/os/ inst.addrepo=appstream,https://mirrors.mit.edu/centos-stream/10-stream/AppStream/x86_64/os/"
  description = "Kernel arguments to boot with."
  type = string
}

variable "kernel_boot_container" {
  default = "centos-kernel-initrd:10"
  description = "Container containing the kernel and initrd."
  type = string
}

variable "kickstart_file" {
  default = "../../kickstart-10-fips.ks"
  description = "File name of the kickstart to add to a secret."
  type = string
}

variable "memory" {
  default = "8Gi"
  description = "Memory to use."
  type = string
}

variable "secure_boot" {
  default = true
  description = "Enables secure boot."
  type = bool
}

variable "sockets" {
  default = 1
  description = "CPU sockets."
  type = number
}

variable "storage_class" {
  default = "ceph-block"
  description = "Storage class to use."
  type = string
}

variable "storage_class_volume_mode" {
  default = "Block"
  description = "Storage class type."
  type = string
}

variable "threads" {
  default = 1
  description = "CPU threads."
  type = number
}

variable "vm_create_timeout" {
  default = "20m"
  description = "How long to wait when creating the VM."
  type = string
}

variable "vm_delete_timeout" {
  default = "30s"
  description = "How long to wait when deleting the VM."
  type = string
}

variable "vm_update_timeout" {
  default = "10m"
  description = "How long to wait when updating the VM."
  type = string
}

variable "volume_label" {
  default = "OEMDRV"
  description = "Volume label to use for the mounted secret."
  type = string
}

output "disk_size" {
  value = module.kickstart_template.disk_size
}

output "storage_class" {
  value = module.kickstart_template.storage_class
}

output "storage_class_volume_mode" {
  value = module.kickstart_template.storage_class_volume_mode
}

output "src_pvc_name" {
  value = module.kickstart_template.src_pvc_name
}

output "src_pvc_namespace" {
  value = module.kickstart_template.src_pvc_namespace
}

output "vm_name" {
  value = module.kickstart_template.vm_name
}

output "vm_namespace" {
  value = module.kickstart_template.vm_namespace
}
