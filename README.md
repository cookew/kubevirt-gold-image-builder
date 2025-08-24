# Purpose

Before you have anything, you need something. This is to create [CentOS Stream](https://www.centos.org/) and [Rocky Linux](https://rockylinux.org/) virtual machines in a consistent and repeatable manner that can then be used for other things.

# Tools Used

- [Podman](https://podman.io/), or [Docker](https://www.docker.com/)
- [OpenTofu](https://opentofu.org/), or [Terraform](https://developer.hashicorp.com/terraform)
- [KubeVirt](https://kubevirt.io/)
- [Kubernetes](https://kubernetes.io/)

# Gold Images

The aim of the gold images is to be small and minimal. Cloud-init is installed for consumption by automation tools.

# Recommendations

For continuous rebuilding and for multiple iterations of testing, it is recommended to host your own RPM repositories of each Linux distribution.

Drawbacks

- Requires lots of space.
- Can consume a lot of bandwidth for the initial sync.
- Your mirror needs to be synchronized periodically.
- You do not get updated packages in your mirror immediately.

Benefits

- Faster to deploy because things are hosted locally.
- Doese not abuse the Linux distrobution mirrors.
- Probably saves on your monthly ISP bandwidth cap.

# How This Works

The build process can be started by using the execute script in the top-level directory. But first, there are things you need to do, so please read through this list to understand to overall flow and to get familiar with it.

1. (you) Ensure kubectl is set up in your environment to work with your kubernetes instance and is logged in.
1. (you) Create the namespace to hold the final gold images.
1. (you) Modify the env files in every directory for your environment.
1. (you) Do a `grep -r wcooke.me *` and modify the files where this is found to customize them for your environment. This is my internal domain and will not work for you. There should be commented lines in those files that you can use instead.
1. (docker) An container will be created with the kernel and initrd files added to them. This will be mounted later by KubeVirt on to the virtual machine that gets created.
1. (docker) The container is pushed to a container registry.
1. (tofu) Create the namespace using a prefix and random characters.
1. (tofu) Create a secret to be used as volume that contains the kickstart file.
1. (tofu) Create a data volume to store the installed operating system.
1. (tofu) Create a virtual machine. This is set to auto boot, mounts the previously created container with the kernel and initrd in it, mounts the empty data volume, and uses UEFI with secure boot.
1. The operating system auto-installs and then shuts down. This can take around 10 minutes.
1. (tofu) If there was an older data volume in the gold namespace, it is deleted.
1. (tofu) The virtual machine's data volume is copied to the gold image namespace using a DataVolume manifest.
1. (tofu) A DataSource manifest is created.
1. (tofu) The namespace and everything in it where the virtual machine was created is deleted.

# Development and Testing Environment

This has been tested and developed in an environment running:

- Debian Linux 12
- Podman 4.3.1
- OpenTofu v1.10.5
- KubeVirt 1.16.0-202507280620
- OKD 4.20.0-okd-scos.ec.10

# To Do

1. Make the final templates that show up in the OKD catalog not have to require me to change the Boot mode from BIOS to UEFI (secure) every time I manually create a VM through the OKD web GUI.
1. Have tofu create all of the necessary KubeVirt templates for a more *complete* experience while using the OKD web GUI.
1. Pipeline for continuous rebuilding.
1. Testing to ensure the gold images built properly.
1. Set up tofu to maintain its state in a remote repository. This will probably be needed for continuous rebuilding in an ephemeral environment.
1. Set up the /etc/yum repos files to use local repos in the kickstart files.
1. Use a locally downloaded copy of the scap security guides in the stig kickstart for CentOS Stream.
