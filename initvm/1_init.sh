#!/bin/bash

apt-get purge -y cloud-init cloud-initramfs-growroot cloud-utils
apt-get install -y aptitude
apt-get autoremove -y --purge ; apt-get autoclean -y

cat $(dirname $0)/sources.list >/etc/apt/sources.list
cat $(dirname $0)/preferences  >/etc/apt/preferences
chmod 644 /etc/apt/{sources.list,preferences}

mkdir /etc/apt/apt.conf.d/disabled
mv /etc/apt/apt.conf.d/20listchanges /etc/apt/apt.conf.d/disabled
aptitude update ; aptitude full-upgrade -y
mv /etc/apt/apt.conf.d/disabled/20listchanges /etc/apt/apt.conf.d

echo 'Europe/Paris' >/etc/timezone
dpkg-reconfigure -f noninteractive tzdata

sed -i 's/^#* *fr_FR/fr_FR/g;s/^ *en_US/# en_US/g' /etc/locale.gen
echo 'LANG="fr_FR.UTF-8"' >/etc/default/locale
dpkg-reconfigure --frontend=noninteractive locales

aptitude install -y git bash-completion lsof vim colordiff ccze most sudo ipset whois

mkdir -p /data/dotfiles
git clone https://github.com/BorX/dotfiles.git /data/dotfiles
/data/dotfiles/install.sh
sudo -uborx /data/dotfiles/home/installIntoHomeDirectory

reboot
