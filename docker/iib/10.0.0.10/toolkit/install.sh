#!/bin/bash

# © Copyright IBM Corporation 2017.
#
# All rights reserved. This program and the accompanying materials
# are made available under the terms of the Eclipse Public License v1.0
# which accompanies this distribution, and is available at
# http://www.eclipse.org/legal/epl-v10.html

. /usr/local/bin/envvars.sh
IIBIMAGE="${IIBTAG}.tar.gz"
export DEBIAN_FRONTEND=noninteractive

echo "iibtk:10.0" > /etc/debian_chroot

# install Git + Toolkit dependencies
apt-get install -y --no-install-recommends libswt-gtk-3-java xvfb git
# now you can xvfb-run mqsicreatebar

# download IIB image
cd /tmp
scp ${SSHUSER}@${HOSTIP}:${IMAGEPATH}/${IIBIMAGE} .

# install IIB tookit
tar xzvf /tmp/${IIBIMAGE} --directory /opt/ibm ${IIBTAG}/tools
rm -rf /tmp/${IIBIMAGE}

# the following is only needed for running the Toolkit interactively
VNCCFGPATH="/var/mqm/.vnc"
VNCPWDFILE="${VNCCFGPATH}/passwd"
mkdir -p ${VNCCFGPATH}
apt-get install -y --no-install-recommends tightvncserver xfwm4 xterm xfonts-base
echo "p4s5w0rd" | vncpasswd -f > ${VNCPWDFILE}
chown -R mqm:mqbrkrs ${VNCCFGPATH}
chmod 600 ${VNCPWDFILE}
echo "USER=mqm vncserver" >> /usr/local/bin/iib-init.sh

# clean up
rm -rf /var/lib/apt/lists/*
