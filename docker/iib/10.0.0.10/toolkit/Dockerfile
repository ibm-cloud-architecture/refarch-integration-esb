# © Copyright IBM Corporation 2017.
#
# All rights reserved. This program and the accompanying materials
# are made available under the terms of the Eclipse Public License v1.0
# which accompanies this distribution, and is available at
# http://www.eclipse.org/legal/epl-v10.html

FROM iib:100010
USER root
COPY install.sh /tmp/
COPY envvars.sh /usr/local/bin/
RUN ["/bin/bash", "/tmp/install.sh"]
EXPOSE 4414 5901 7800
USER mqm
#ENTRYPOINT ["/usr/local/bin/iib-manage.sh"]
