# � Copyright IBM Corporation 2017.
#
# All rights reserved. This program and the accompanying materials
# are made available under the terms of the Eclipse Public License v1.0
# which accompanies this distribution, and is available at
# http://www.eclipse.org/legal/epl-v10.html

# Changes to create IIB+MQ image marked #IIBMQ

#IIBMQ Build from mq image (assumes there is a local image, called "mq")

FROM mqbase:904

MAINTAINER Callum Jackson callumj@uk.ibm.com

# curl is already in mqbase image
# install iib runtime only, so excluding toolkit.
RUN mkdir /opt/ibm && \
    curl http://public.dhe.ibm.com/ibmdl/export/pub/software/websphere/integration/10.0.0.10-IIB-LINUX64-DEVELOPER.tar.gz \
    | tar zx --exclude iib-10.0.0.10/tools --directory /opt/ibm && \
    /opt/ibm/iib-10.0.0.10/iib make registry global accept license silently

# Configure system
COPY kernel_settings.sh /tmp/
RUN echo "IIB_10:" > /etc/debian_chroot  && \
    touch /var/log/syslog && \
    chown syslog:adm /var/log/syslog && \
    chmod +x /tmp/kernel_settings.sh;sync && \
    /tmp/kernel_settings.sh


#IIBMQ Add mqm to list of groups iibuser is member of
RUN useradd --create-home --home-dir /home/iibuser -G mqbrkrs,sudo,mqm iibuser && \
    sed -e 's/^%sudo	.*/%sudo	ALL=NOPASSWD:ALL/g' -i /etc/sudoers

# Increase security
RUN sed -i 's/sha512/sha512 minlen=8/'  /etc/pam.d/common-password && \
    sed -i 's/PASS_MIN_DAYS\t0/PASS_MIN_DAYS\t1/'  /etc/login.defs && \
    sed -i 's/PASS_MAX_DAYS\t99999/PASS_MAX_DAYS\t90/'  /etc/login.defs

#IIBMQ Copy all iib*.sh scripts
COPY iib*.sh /usr/local/bin/
RUN chmod +rx /usr/local/bin/iib*.sh
ENV LICENSE accept
#ADD integration /integration
#RUN /bin/bash  -c "source /opt/ibm/iib-10.0.0.10/server/bin/mqsiprofile; mqsipackagebar -a /iibApp.bar -w /integration -k RESTAPI"

# Set BASH_ENV to source mqsiprofile when using docker exec bash -c
ENV BASH_ENV=/usr/local/bin/iib_env.sh
ENV MQSI_MQTT_LOCAL_HOSTNAME=127.0.0.1

# Expose default admin port and http port
EXPOSE 4414 7800

USER iibuser

# Set entrypoint to run management script
ENTRYPOINT ["iib_manage.sh"]
