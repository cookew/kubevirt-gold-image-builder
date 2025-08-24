# https://docs.redhat.com/en/documentation/red_hat_enterprise_linux/10/html/automatically_installing_rhel/kickstart-commands-and-options-reference
# https://docs.fedoraproject.org/en-US/fedora/f34/install-guide/appendixes/Kickstart_Syntax_Reference/#sect-kickstart-commands-part
# https://docs.redhat.com/en/documentation/red_hat_enterprise_linux/10/html/security_hardening/scanning-the-system-for-configuration-compliance#performing-a-hardened-installation-of-rhel-with-kickstart
# https://docs.redhat.com/en/documentation/red_hat_enterprise_linux/10/html-single/security_hardening/index

eula --agreed
firewall --enabled
firstboot --disable
keyboard --vckeymap=us --xlayouts='us'
lang en_US.UTF-8
poweroff
selinux --enforcing
# 2025-08-24 CentOS 10 breaks when installing usbguard in the kickstart, oscap remediation will install it and enable it.
#services --disabled=debug-shell,autofs,kdump --enabled=pcscd,rsyslog,systemd-journald,firewalld,fapolicyd,chronyd,sshd,sssd,usbguard,auditd
services --disabled=debug-shell,autofs,kdump --enabled=pcscd,rsyslog,systemd-journald,firewalld,fapolicyd,chronyd,sshd,sssd,auditd
skipx
text --non-interactive
timesource --ntp-server=ntp.wcooke.me
timezone America/Denver --utc

# encrypted password is password
bootloader --boot-drive=vda --location=mbr --timeout=1 --append="audit=1 audit_backlog_limit=8192 init_on_free=1 page_poison=1 pti=on vsyscall=none fips=1" --password=$6$zgBo0hTih3V5af3c$8jHfmwAueVZUX8snAT5dQ7p2cUEOR8dhh/im7KY4a7op6azfa5o.GGEFUTm6mkrP5EPmzPlN9FH4e9cOFHJbb.
clearpart --all --drives=vda --disklabel=gpt --initlabel
ignoredisk --only-use=vda
reqpart --add-boot
part pv.01 --grow
volgroup vg pv.01

logvol /              --vgname=vg --name=root   --fstype=xfs --size=4096
logvol /home          --vgname=vg --name=home   --fstype=xfs --size=1024  --fsoptions="defaults,nodev,noexec,nosuid"
logvol /tmp           --vgname=vg --name=tmp    --fstype=xfs --size=1024  --fsoptions="defaults,nodev,noexec,nosuid"
logvol /var           --vgname=vg --name=var    --fstype=xfs --size=4096  --fsoptions="defaults,nodev"
logvol /var/log       --vgname=vg --name=log    --fstype=xfs --size=2048  --fsoptions="defaults,nodev,noexec,nosuid"
logvol /var/log/audit --vgname=vg --name=audit  --fstype=xfs --size=10240 --fsoptions="defaults,nodev,noexec,nosuid"
logvol /var/tmp       --vgname=vg --name=vartmp --fstype=xfs --size=2048  --fsoptions="defaults,nodev,noexec,nosuid"

# encrypted password is password
rootpw --iscrypted $6$zgBo0hTih3V5af3c$8jHfmwAueVZUX8snAT5dQ7p2cUEOR8dhh/im7KY4a7op6azfa5o.GGEFUTm6mkrP5EPmzPlN9FH4e9cOFHJbb.

%addon com_redhat_kdump --disable
%end

%packages --inst-langs=en
# This is the list generated using oscap
-gdm
-gssproxy
-nfs-utils
-telnet-server
-tftp
-tftp-server
-tuned
-unbound
-vsftpd
aide
audispd-plugins
audit
chrony
cronie
crypto-policies
fapolicyd
firewalld
gnutls-utils
libreswan
nss-tools
opensc
openscap-scanner
openssh-clients
openssh-server
pcsc-lite
pcsc-lite-ccid
pkcs11-provider
policycoreutils
policycoreutils-python-utils
rsyslog
rsyslog-gnutls
s-nail
scap-security-guide
sssd
subscription-manager
sudo
# 2025-08-24 CentOS 10 breaks when installing usbguard in the kickstart.
# There is a problem during the configuring phase of the package.
# The oscap utility will install usbguard anyways as part of the remediateion,
# and so, doesn't necessarily need to be included here for any distro.
#usbguard

# This is a custom list to slim the install down to just what it needs
-amd-*
-atheros-*
-brcmfmac*
-cirrus-*
-cockpit
-insights-client
-intel-*
-irqbalance
-iwl*
-langpacks
-mt7xxx-*
-NetworkManager-team
-NetworkManager-tui
-nvidia-*
-nxpwireless-*
-plymouth*
-realtek-*
-tiwilink-*
@^minimal-environment
cloud-init
cloud-utils-growpart
%end

%post --interpreter bash --log /root/oscap.log --erroronfail
date > /etc/build-date

source /etc/os-release
if [ "${ID}" = "centos" ]
then
  # Subscription manager doesn't do anything on non-RHEL linux, so disable it.
  sed -i 's/enabled=1/enabled=0/g' /etc/dnf/pludgins/subscription-manager.conf

  # 2025-08.23 Get a verson of the oscap that guides that work from GitHub. The version included in CentoOS returns results as not applicaple for every STIG.
  dnf install -y tar
  SCAP_GUIDE_VERSION=0.1.77
  curl -OL https://github.com/ComplianceAsCode/content/releases/download/v${SCAP_GUIDE_VERSION}/scap-security-guide-${SCAP_GUIDE_VERSION}.tar.gz --output-dir /root
  tar zxf /root/scap-security-guide-${SCAP_GUIDE_VERSION}.tar.gz -C /root
  oscap --verbose INFO --verbose-log-file /root/oscap_verbose.log xccdf eval --remediate --results-arf /root/oscap_arf.xml --stig-viewer /root/oscap_stig-viewer.ckb --report /root/oscap_report.html --profile 'xccdf_org.ssgproject.content_profile_stig' /root/scap-security-guide-${SCAP_GUIDE_VERSION}/ssg-cs10-ds.xml
  rm -rf /root/scap-security-guide-${SCAP_GUIDE_VERSION}*
elif [ "${ID}" = "rocky" ]
then
  oscap --verbose INFO --verbose-log-file /root/oscap_verbose.log xccdf eval --remediate --results-arf /root/oscap_arf.xml --stig-viewer /root/oscap_stig-viewer.ckb --report /root/oscap_report.html --profile 'xccdf_org.ssgproject.content_profile_stig' /usr/share/xml/scap/ssg/content/ssg-rl10-ds.xml
else
  oscap --verbose INFO --verbose-log-file /root/oscap_verbose.log xccdf eval --remediate --results-arf /root/oscap_arf.xml --stig-viewer /root/oscap_stig-viewer.ckb --report /root/oscap_report.html --profile 'xccdf_org.ssgproject.content_profile_stig' /usr/share/xml/scap/ssg/content/ssg-rhel10-ds.xml
fi

[ $? -eq 0 -o $? -eq 2 ] || exit 1
%end
