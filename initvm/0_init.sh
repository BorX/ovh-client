#!/bin/bash

export PATH=$PATH:/sbin:/usr/sbin:/bin

ip6tables -P INPUT   DROP
ip6tables -P OUTPUT  DROP
ip6tables -P FORWARD DROP
iptables -P INPUT   DROP
iptables -P OUTPUT  DROP
iptables -P FORWARD DROP
iptables -m comment --comment " IN SSH  " -i eth0 -A  INPUT -p tcp --dport  443 -j ACCEPT
iptables -m comment --comment " IN SSH  " -o eth0 -A OUTPUT -p tcp --sport  443 -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT
iptables -m comment --comment "OUT NTP  " -o eth0 -A OUTPUT -p udp --dport  123 -j ACCEPT
iptables -m comment --comment "OUT NTP  " -i eth0 -A  INPUT -p udp --sport  123 -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT
iptables -m comment --comment "OUT DNS  " -o eth0 -A OUTPUT -p udp --dport   53 -j ACCEPT
iptables -m comment --comment "OUT DNS  " -i eth0 -A  INPUT -p udp --sport   53 -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT
iptables -m comment --comment "OUT HTTP " -o eth0 -A OUTPUT -p tcp --dport   80 -j ACCEPT
iptables -m comment --comment "OUT HTTP " -i eth0 -A  INPUT -p tcp --sport   80 -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT
iptables -m comment --comment "OUT HTTPS" -o eth0 -A OUTPUT -p tcp --dport  443 -j ACCEPT
iptables -m comment --comment "OUT HTTPS" -i eth0 -A  INPUT -p tcp --sport  443 -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT
iptables -m comment --comment "OUT SMTP " -o eth0 -A OUTPUT -p tcp --dport   25 -j ACCEPT
iptables -m comment --comment "OUT SMTP " -i eth0 -A  INPUT -p tcp --sport   25 -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT
iptables -m comment --comment "OUT Whois" -o eth0 -A OUTPUT -p tcp --dport   43 -j ACCEPT
iptables -m comment --comment "OUT Whois" -i eth0 -A  INPUT -p tcp --sport   43 -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT
iptables -m comment --comment "OUT Whois" -o eth0 -A OUTPUT -p tcp --dport 4321 -j ACCEPT
iptables -m comment --comment "OUT Whois" -i eth0 -A  INPUT -p tcp --sport 4321 -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT
iptables -m comment --comment "NO_LOG_POLLUTION:Port  21" -A INPUT -p tcp --dport  21 -j DROP
iptables -m comment --comment "NO_LOG_POLLUTION:Port  22" -A INPUT -p tcp --dport  22 -j DROP
iptables -m comment --comment "NO_LOG_POLLUTION:Port  23" -A INPUT -p tcp --dport  23 -j DROP
iptables -m comment --comment "NO_LOG_POLLUTION:Port  80" -A INPUT -p tcp --dport  80 -j DROP
iptables -m comment --comment "NO_LOG_POLLUTION:Port 443" -A INPUT -p tcp --dport 443 -j DROP
iptables -m comment --comment "Logs                     " -A INPUT  -j LOG --log-prefix " [INPUT DROPPED] "
iptables -m comment --comment "Logs     "                 -A OUTPUT -j LOG --log-prefix "[OUTPUT DROPPED] "

# mkpasswd --method=sha-512 the-password
usermod -aG sudo -md /home/myuser -l myuser --password '$6$2AmnAKMiIhOt3sY6$N.v3igMQHu9ImrkHMz/N4j5EIeb3ETSZn8l.vpT.nRL2EtEN.lPqDJzoA/gOmpa8R7y0t1h5.isxFqrJRDjrq.' debian
groupmod -n mygroup debian
rm /etc/sudoers.d/90-cloud-init-users

sed -i 's/#*Port 22/Port 443/gi;s/#*PermitRootLogin yes/PermitRootLogin no/gi;s/#*X11Forwarding yes/X11Forwarding no/gi;s/#*PasswordAuthentication yes/PasswordAuthentication no/gi' /etc/ssh/sshd_config
echo 'AllowUsers myuser' >>/etc/ssh/sshd_config
systemctl daemon-reload
systemctl restart ssh

