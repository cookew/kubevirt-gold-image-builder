resource "kubernetes_namespace" "vm-namespace" {
  metadata {
    generate_name = var.builder_prefix
  }
  lifecycle {
    ignore_changes = [
      metadata[0].annotations
    ]
  }
}

resource "kubernetes_secret" "vm-kickstart-secret" {
  metadata {
    name      = join("-", [var.builder_prefix, "kickstart"])
    namespace = kubernetes_namespace.vm-namespace.metadata[0].name
  }
  data = {
    "ks.cfg" = file(var.kickstart_file)
  }
  depends_on = [
    kubernetes_namespace.vm-namespace
  ]
}

resource "kubernetes_manifest" "vm-rootdisk" {
  manifest = {
    apiVersion = "cdi.kubevirt.io/v1beta1"
    kind       = "DataVolume"
    metadata = {
      name      = join("-", [var.builder_prefix, "rootdisk"])
      namespace = kubernetes_namespace.vm-namespace.metadata[0].name
    }
    spec = {
      source = {
        blank = {}
      }
      storage = {
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
  depends_on = [
    kubernetes_namespace.vm-namespace
  ]
  wait {
    fields = {
      "status.phase" = "Succeeded"
    }
  }
}

resource "kubernetes_manifest" "vm" {
  manifest = {
    apiVersion = "kubevirt.io/v1"
    kind       = "VirtualMachine"
    metadata = {
      name      = var.builder_prefix
      namespace = kubernetes_namespace.vm-namespace.metadata[0].name
    }
    spec = {
      runStrategy = "RerunOnFailure"
      template = {
        spec = {
          architecture = var.architecture
          domain = {
            cpu = {
              cores   = var.cores
              sockets = var.sockets
              threads = var.threads
            }
            devices = {
              disks = [
                {
                  disk = {
                    bus = "virtio"
                  }
                  name = "rootdisk"
                },
                {
                  disk = {
                    bus = "virtio"
                  }
                  name = "kickstart"
                }
              ]
              inputs = [
                {
                  bus = "virtio"
                  name = "tablet"
                  type = "tablet"
                }
              ]
              interfaces = [
                {
                  masquerade = {}
                  model  = "virtio"
                  name   = "default"
                }
              ]
              rng = {}
              tpm = {
                persistent: true
              }
            }
            features = {
              acpi = {}
              smm = {
                enabled = true
              }
            }
            firmware = {
              bootloader = {
                efi = {
                  persistent = true
                  secureBoot = var.secure_boot
                }
              }
              kernelBoot = {
                container = {
                  image = join("/", [var.container_registry, var.kernel_boot_container])
                  initrdPath = "/initrd"
                  kernelPath = "/vmlinuz"
                  imagePullPolicy = "Always"
                }
                kernelArgs = var.kernel_args
              }
            }
            machine = {
              type = "q35"
            }
            memory = {
              guest = var.memory
            }
            resources = {}
          }
          networks = [
            {
              name = "default"
              pod = {}
            }
          ]
          terminationGracePeriodSeconds = 1
          volumes = [
            {
              dataVolume = {
                name = kubernetes_manifest.vm-rootdisk.object.metadata.name
              }
              name = "rootdisk"
            },
            {
              name = "kickstart"
              secret = {
                secretName = kubernetes_secret.vm-kickstart-secret.metadata[0].name
                volumeLabel = var.volume_label
              }
            }
          ]
        }
      }
    }
  }
  computed_fields = [
    "metadata.annotations",
    "metadata.labels",
    "spec.dataVolumeTemplates.metadata.creationTimestamp",
    "spec.template.metadata.creationTimestamp",
    "spec.template.spec.domain.devices.firmware.uuid",
    "spec.template.spec.domain.devices.interfaces.macAddress"
  ]
  depends_on = [
    kubernetes_namespace.vm-namespace,
    kubernetes_manifest.vm-rootdisk,
    kubernetes_secret.vm-kickstart-secret
  ]
  timeouts {
    create = var.vm_create_timeout
    delete = var.vm_delete_timeout
    update = var.vm_update_timeout
  }
}
