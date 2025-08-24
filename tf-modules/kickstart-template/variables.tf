variable "builder_prefix" {
  default = "vm-template"
  description = "Prefix name for the namespace."
  type = string
}

variable "kickstart_file" {
  default = "rocky-linux10.ks"
  description = "File name of the kickstart to add to a secret."
  type = string
}

variable "container_registry" {
  default = "hub.docker.io"
  description = "Container registry for the container."
  type = string
}

variable "kernel_boot_container" {
  default = "rocky-kernel-initrd:10"
  description = "Container containing the kernel and initrd."
  type = string
}

variable "disk_size" {
  default = "26Gi"
  description = "Volume size to create."
  type = string
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

variable "kernel_args" {
  default = "inst.noverifyssl inst.geoloc=0 vga=795 fips=1 hostname=rocky-linux10-gold inst.repo=https://dl.rockylinux.org/pub/rocky/10/BaseOS/x86_64/os/"
  description = "Kernel arguments to boot with."
  type = string
}

variable "volume_label" {
  default = "OEMDRV"
  description = "Volume label to use for the mounted secret."
  type = string
}

variable "architecture" {
  default = "amd64"
  description = "Hardware architecture."
  type = string
}

variable "cores" {
  default = 4
  description = "Cores per CPU."
  type = number
}

variable "sockets" {
  default = 1
  description = "CPU sockets."
  type = number
}

variable "threads" {
  default = 1
  description = "CPU threads."
  type = number
}

variable "secure_boot" {
  default = true
  description = "Enables secure boot."
  type = bool
}

variable "memory" {
  default = "8Gi"
  description = "Memory to use."
  type = string
}

variable "vm_create_timeout" {
  default = "20m"
  description = "How long to wait when creating the VM."
  type = string
}

variable "vm_update_timeout" {
  default = "10m"
  description = "How long to wait when updating the VM."
  type = string
}

variable "vm_delete_timeout" {
  default = "30s"
  description = "How long to wait when deleting the VM."
  type = string
}
