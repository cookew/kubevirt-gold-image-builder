variable "disk_size" {
  default = "8Gi"
  description = "Volume size to create."
  type = string
}

variable "image_name" {
  default = "linux10-gold"
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
    default = "linux10-rootdisk"
    description = "PVC name for the source pvc of the image to copy."
    type = string
}

variable "src_pvc_namespace" {
    default = "vm-template-linux10"
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
