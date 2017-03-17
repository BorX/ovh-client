#!/bin/bash

export PATH=$PATH:/sbin:/usr/sbin:/bin

mv "$(dirname "$0")/iptables-init" /etc/
chown -R 0:0 /etc/iptables-init/
chmod 700 /etc/iptables-init/init
/etc/iptables-init/init --quiet start

# mkpasswd --method=sha-512 the-password
usermod -aG sudo -md /home/myuser -l myuser --password '$6$2AmnAKMiIhOt3sY6$N.v3igMQHu9ImrkHMz/N4j5EIeb3ETSZn8l.vpT.nRL2EtEN.lPqDJzoA/gOmpa8R7y0t1h5.isxFqrJRDjrq.' debian
groupmod -n mygroup debian
rm /etc/sudoers.d/90-cloud-init-users

sed -i 's/#*Port 22/Port 443/gi;s/#*PermitRootLogin yes/PermitRootLogin no/gi;s/#*X11Forwarding yes/X11Forwarding no/gi;s/#*PasswordAuthentication yes/PasswordAuthentication no/gi' /etc/ssh/sshd_config
echo 'AllowUsers myuser' >>/etc/ssh/sshd_config
systemctl daemon-reload
systemctl restart ssh

mv "$(dirname "$0")/dotfiles" /etc/
chown -R 0:0 /etc/dotfiles/
/etc/dotfiles/install.sh
chmod 755 /etc/dotfiles/home/installIntoHomeDirectory
sudo -umyuser /etc/dotfiles/home/installIntoHomeDirectory
