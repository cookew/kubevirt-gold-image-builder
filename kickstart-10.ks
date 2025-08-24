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
skipx
text --non-interactive
timesource --ntp-server=ntp.wcooke.me
timezone America/Denver --utc

# encrypted password is password
bootloader --boot-drive=vda --location=mbr --timeout=1 --append="audit=1 audit_backlog_limit=8192 init_on_free=1 page_poison=1 pti=on vsyscall=none" --password=$6$zgBo0hTih3V5af3c$8jHfmwAueVZUX8snAT5dQ7p2cUEOR8dhh/im7KY4a7op6azfa5o.GGEFUTm6mkrP5EPmzPlN9FH4e9cOFHJbb.
clearpart --all --drives=vda --disklabel=gpt --initlabel
ignoredisk --only-use=vda
reqpart --add-boot
part pv.01 --grow
volgroup vg pv.01

logvol /              --vgname=vg --name=root   --fstype=xfs --size=2048
#logvol /home          --vgname=vg --name=home   --fstype=xfs --size=1024  --fsoptions="defaults,nodev,noexec,nosuid"
#logvol /tmp           --vgname=vg --name=tmp    --fstype=xfs --size=1024  --fsoptions="defaults,nodev,noexec,nosuid"
#logvol /var           --vgname=vg --name=var    --fstype=xfs --size=4096  --fsoptions="defaults,nodev"
#logvol /var/log       --vgname=vg --name=log    --fstype=xfs --size=2048  --fsoptions="defaults,nodev,noexec,nosuid"
#logvol /var/log/audit --vgname=vg --name=audit  --fstype=xfs --size=10240 --fsoptions="defaults,nodev,noexec,nosuid"
#logvol /var/tmp       --vgname=vg --name=vartmp --fstype=xfs --size=2048  --fsoptions="defaults,nodev,noexec,nosuid"

# encrypted password is password
rootpw --iscrypted $6$zgBo0hTih3V5af3c$8jHfmwAueVZUX8snAT5dQ7p2cUEOR8dhh/im7KY4a7op6azfa5o.GGEFUTm6mkrP5EPmzPlN9FH4e9cOFHJbb.

#%addon com_redhat_kdump --disable
#%end

%packages --inst-langs=en
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
-subscription-manager*
@^minimal-environment
cloud-init
cloud-utils-growpart
%end

%post
date > /etc/build-date
%end
