output "disk_size" {
  value = kubernetes_manifest.vm-rootdisk.object.spec.storage.resources.requests.storage
}

output "src_pvc_name" {
  value = kubernetes_manifest.vm-rootdisk.object.metadata.name
}

output "src_pvc_namespace" {
  value = kubernetes_manifest.vm-rootdisk.object.metadata.namespace
}

output "storage_class" {
  value = kubernetes_manifest.vm-rootdisk.object.spec.storage.storageClassName
}

output "storage_class_volume_mode" {
  value = kubernetes_manifest.vm-rootdisk.object.spec.storage.volumeMode
}

output "vm_name" {
  value = kubernetes_manifest.vm.object.metadata.name
}

output "vm_namespace" {
  value = kubernetes_manifest.vm.object.metadata.namespace
}
