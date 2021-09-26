# Multipass KVM
```
snap install multipass
apt install libvirt-daemon-system
snap connect multipass:libvirt
multipass set local.driver=libvirt
```

# Cloud-Init to set Ubuntu User
```
cat <<'EOF'> multipass.yaml
#cloud-config
system_info:
  default_user:
    name: ubuntu
    gecos: Ubuntu
password: pass
chpasswd: { expire: False }
ssh_pwauth: True
ssh_authorized_keys:
  - ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDFOvXax9dNqU2unqd+AZQ+VSe2cZZbGMVRuzIW4Hl6Ji69R0zkWih0vuP2psRA/uWTg1XqFKisCp9Z1XQcBbH2WLhnIWhykeLOHtBdEQqUApKj+BrKnyDmBbCourUwAcuUQSRPeRBOg5hwReviIebwvELmwc8ab1r0X+nbCDwVdohTpwNnxHp5MTO0WADLdP0oDQy2hhVaiParCWdVvgfDauQ2IpgeN6tE5sUvsDyYLaYp/dIhddA/Dwh9sWEFfN7ERMSHJw/A/3GsQ49a8+w6lamgcfNDKK7hE9F5vn95fzhge0jj6Yl8NTXOzoMfpvPo3Q+uCbu+GRMlRAK3hcHP wilton.pem
runcmd:
    - |
      # Fix Oracle Linux Serial Console
      if [ -e /etc/system-release ]; then
        if [ "$(sed 's, release .*$,,g' /etc/system-release)" == "Oracle Linux Server" ]; then 
          if ! grep ttyS0 /etc/default/grub; then
            sed -i "s/console=tty0/console=ttyS0,115200n8 console=tty0/g" /etc/default/grub;
            grub2-mkconfig -o /boot/grub2/grub.cfg;
            echo "Serial Console Fixed... Rebooting...";
            reboot;
          fi
        fi
      fi
EOF
```

# Ubuntu
```
multipass launch -n primary -v -c 1 -m 1G -d 10G --cloud-init multipass.yaml 20.04
multipass exec primary -- bash
```

# Debian
```
debian_img=http://cloud.debian.org/images/cloud/bullseye/latest/debian-11-generic-amd64.qcow2
multipass launch -n debian -v -c 2 -m 2G -d 10G --cloud-init multipass.yaml $debian_img
multipass exec debian -- bash
```

# Oracle Linux 8
```
oracle_linux_8_img=https://yum.oracle.com/templates/OracleLinux/OL8/u4/x86_64/OL8U4_x86_64-olvm-b85.qcow2
multipass launch -n oracle-linux-8 -v -c 2 -m 2G -d 40G --cloud-init multipass.yaml $oracle_linux_8_img
multipass exec oracle-linux-8 -- bash
```

# Oracle Linux 7
```
oracle_linux_7_img=https://yum.oracle.com/templates/OracleLinux/OL7/u9/x86_64/OL7U9_x86_64-olvm-b86.qcow2
multipass launch -n oracle-linux-7 -v -c 2 -m 2G -d 40G --cloud-init multipass.yaml $oracle_linux_7_img
multipass exec oracle-linux-7 -- bash
```

# CentOS 7
```
centos_img=https://cloud.centos.org/altarch/7/images/CentOS-7-x86_64-GenericCloud.qcow2
multipass launch -n centos -v -c 1 -m 1G -d 10G --cloud-init multipass.yaml $centos_img
multipass exec centos -- bash
```

# Cleanup
```
multipass delete primary debian oracle-linux-8 oracle-linux-7 centos
multipass purge
```