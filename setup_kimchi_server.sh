#!/bin/bash

work_dir="/root"
python3_ver="3.8.1"
python3_tarball="Python-${python3_ver}.tar.xz"
python3_repo="https://www.python.org/ftp/python/${python3_ver}/${python3_tarball}"
python3_dir="/root/Python-${python3_ver}"
suse_relver=`cat /etc/issue | grep -oE "SUSE Linux Enterprise Server [0-9]{1,}" | grep -oE "[0-9]{1,}"`
nginx_repo="http://nginx.org/packages/sles/${suse_relver}"
nginx_signing_key="https://nginx.org/keys/nginx_signing.key"
nginx_signing_key_local="/tmp/nginx_signing.key"
nginx_service="nginx"
wok_repo="https://github.com/kimchi-project/wok.git"
wok_dir="/root/wok"
kimchi_repo="https://github.com/kimchi-project/kimchi.git"
kimchi_dir="/root/wok/kimchi"
suse_factory_repo="http://download.suse.de/ibs/SUSE:/Factory:/Head/standard/"

##### Install basic support packages #####
cd ${work_dir}
sudo zypper --non-interactive install -y sudo wget curl git zlib-devel bzip2-devel openssl-devel ncurses-devel sqlite-devel 
sudo zypper --non-interactive install -y readline-devel tk-devel gdbm-devel db4-devel libpcap-devel xz-devel libffi-devel

##### Install Python3 #####
sudo wget ${python3_repo}
sudo tar xvf ${python3_tarball} 
cd ${python3_dir}
sudo ./configure
sudo make
sudo make install
sudo zypper --non-interactive install -y python3-pip
sudo pip insall --uprade pip

##### Setup Nginx #####
sudo zypper --non-interactive install -y curl ca-certificates gpg2 
sudo zypper addrepo --gpgcheck --type yum --refresh --check ${nginx_repo} nginx-stable 
sudo curl -o ${nginx_signing_key_local} ${nginx_signing_key} 
sudo gpg --with-fingerprint ${nginx_signing_key_local} 
sudo rpmkeys --import ${nginx_signing_key_loca} 
sudo zypper --gpg-auto-import-keys ref
sudo zypper --non-interactive install -y nginx
echo -e "NGINX DONE\n"

##### Setup Wok #####
sudo git clone ${wok_repo}
sudo zypper --non-interactive install -y gcc make autoconf automake git python3-pip python3-requests python3-mock gettext-tools rpm_build
suod zypper --non-interactive install -y libxslt-tools gcc-c++ python3-devel python3-pep8 python3-pyflakes rpmlint python3-PyYAML python3-distro
sudo pip3 install mock
sudo pip3 install pep8
sudo pip3 install pyflakes
sudo zypper --non-interactive install -y systemd logrotate python3-psutil python3-ldap python3-lxml python3-websockify python3-jsonschema 
sudo zypper --non-interactive install -y openssl nginx python3-CherryPy python3-Cheetah3 python3-python-pam python3-M2Crypto gettext-tools python3-distro
sudo zypper --non-interactive install -y *Crypt*
sudo pip3 install Cheetah3
sudo pip3 install jsonschema
sudo pip3 install pam
sudo pip3 install python-pam
sudo pip3 install cherrypy
sudo zypper --non-interactive install -y openldap*
sudo pip3 install  python-ldap
sudo pip3 install lxml
sudo pip3 install psutil
sudo pip3 install websockify
cd ${wok_dir}
sudo pip3 install -r requirements-dev.txt
sduo ./autogen.sh --system
sudo make
sudo make install
echo -e "WOK DONE\n"

##### Setup Kimchi #####
sudo git clone ${kimchi_repo}
sudo zypper --non-interactive install -y python3-configobj python3-lxml python3-magic python3-paramiko python3-ldap python3-html5 python3-libvirt-python 
sudo zypper --non-interactive install -y novnc qemu-kvm python3-ethtool python3-Pillow python3-CherryPy python3-ipaddr python3-libguestfs parted-devel 
sudo zypper --non-interactive install -y libvirt libvirt-d aemon-config-network open-iscsi guestfs-tools nfs-clien gcc python3-devel
sudo pip3 install Pillow
sudo pip3 install html5
sudo pip3 install paramiko
sudo pip3 install spice
sudo pip3 install python-magic
sudo zypper --non-interactive install -y libnl*
sudo zypper --non-interactive install -y ethtool*
sudo pip3 install ethtool
sduo zypper --non-interactive install -y part*
sduo zypper --non-interactive install -y libpart*
sudo pip3 install pyparted
sudo zypper --non-interactive --no-gpg-check ar -f ${suse_factory_repo} suse_factory
sudo zypper --non-interactive --gpg-auto-import-keys ref
sudo zypper --non-interactive install -y spice-html5
sudo zypper --non-interactive rr suse_factory
cd ${kimchi_dir}
sudo pip3 install -r requirements-dev.txt
sudo pip3 install -r requirements-OPENSUSE-LEAP.txt
sudo ./autogen.sh --system
sudo make 
sudo make install
sudo make local-check
sduo make check
echo -e "KIMCHI DONE\n"
##### Sart up services #####
echo -e "STARTING SERVICES(NGINX,WOKD)\n"
sudo systemctl enable ${nginx_service}
sudo systemctl start ${nginx_service}
sudo systemctl status ${nginx_service}
sudo systemctl enable ${wok_service}
sudo systemctl start ${wok_service}
sudo systemctl status ${wok_service}
echo -e "SERVICES(NGINX,WOKD) DONE\n"
echo -e "Recommend reboot system if anything does not work\n"
