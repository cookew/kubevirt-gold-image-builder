resource "kubernetes_manifest" "vm-datavolume" {
  manifest = {
    apiVersion = "cdi.kubevirt.io/v1beta1"
    kind       = "DataVolume"
    metadata = {
      name      = var.image_name
      namespace = var.images_namespace
    }
    spec = {
      source = {
        pvc = {
            name = var.src_pvc_name
            namespace = var.src_pvc_namespace
        }
      }
      pvc = {
        accessModes = ["ReadWriteMany"]
        resources = {
          requests = {
            storage = var.disk_size
          }
        }
        storageClassName = var.storage_class
        volumeMode = var.storage_class_volume_mode
      }
    }
  }
  wait {
    fields = {
      "status.phase" = "Succeeded"
    }
  }
}

resource "kubernetes_manifest" "vm-image-datasource" {
  manifest = {
    apiVersion = "cdi.kubevirt.io/v1beta1"
    kind       = "DataSource"
    metadata = {
      labels = {
        "instancetype.kubevirt.io/default-instancetype" = var.kubevirt_instancetype
        "instancetype.kubevirt.io/default-preference" = var.kubevirt_preference
      }
      name      = kubernetes_manifest.vm-datavolume.object.metadata.name
      namespace = kubernetes_manifest.vm-datavolume.object.metadata.namespace
    }
    spec = {
      source = {
        pvc = {
          name = kubernetes_manifest.vm-datavolume.object.metadata.name
          namespace = kubernetes_manifest.vm-datavolume.object.metadata.namespace
        }
      }
    }
  }
  depends_on = [
    kubernetes_manifest.vm-datavolume
  ]
}
