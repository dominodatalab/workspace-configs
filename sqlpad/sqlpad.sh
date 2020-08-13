#!/bin/bash
# Download SQLPAD and build it
cd /opt && \
git clone https://github.com/rickbergfalk/sqlpad.git && \
cd /opt/sqlpad && sudo scripts/build.sh

# Fix it up to be usable
sed -i 's/..\/db/\/mnt\/sqlpaddb/g' /opt/sqlpad/server/config.dev.env && \
sudo echo 'SQLPAD_AUTH_DISABLED = true' >> /opt/sqlpad/server/config.dev.env && \
sudo echo 'SQLPAD_AUTH_DISABLED = true' >> /opt/sqlpad/server/config.dev.env &&  \
sudo echo 'SQLPAD_AUTH_DISABLED_DEFAULT_ROLE = admin' >> /opt/sqlpad/server/config.dev.env && \
cat /opt/sqlpad/server/config.dev.env