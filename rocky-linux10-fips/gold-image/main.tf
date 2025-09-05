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

module "gold-image" {
  source = "../../tf-modules/gold-image"
  disk_size = var.disk_size
  image_name = var.image_name
  images_namespace = var.images_namespace
  kubevirt_instancetype = var.kubevirt_instancetype
  kubevirt_preference = var.kubevirt_preference
  src_pvc_name = var.src_pvc_name
  src_pvc_namespace = var.src_pvc_namespace
  storage_class = var.storage_class
  storage_class_volume_mode = var.storage_class_volume_mode
}

variable "kube_config" {
  default = "~/.kube/config"
}

variable "kube_context" {
  default = "default"
}

variable "disk_size" {
  default = "8Gi"
  description = "Volume size to create."
  type = string
}

variable "image_name" {
  default = "rocky-linux10-gold"
  description = "Name of the gold image to create."
  type = string
}

variable "images_namespace" {
  default = "vm-templates"
  description = "Namespace to store the gold images."
  type = string
}

variable "kubevirt_instancetype" {
  default = "u1.small"
  description = "Default kubevirt instance type."
  type = string
}

variable "kubevirt_preference" {
  default = ""
  description = "Default kubevirt preference."
  type = string
}

variable "src_pvc_name" {
    default = "rocky-linux10-rootdisk"
    description = "PVC name for the source pvc of the image to copy."
    type = string
}

variable "src_pvc_namespace" {
    default = "vm-template-rocky-linux10"
    description = "Namespace for the source pvc of the image to copy."
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
