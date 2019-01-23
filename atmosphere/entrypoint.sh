#!/bin/bash
MANAGE_CMD="/opt/env/atmo/bin/python /opt/dev/atmosphere/manage.py"

# Clone secrets repo
mkdir ~/.ssh
echo -e $SSH_KEY > /opt/my_key
chmod 600 /opt/my_key
echo -e "Host gitlab.cyverse.org\n\tStrictHostKeyChecking no\n\tIdentityFile /opt/my_key" >> ~/.ssh/config
git clone $SECRETS_REPO $SECRETS_DIR

# Setup SSH keys
. $SECRETS_DIR/atmo_vars.env
mkdir /opt/dev/atmosphere/extras/ssh
cp $SSH_PRIV_KEY /opt/dev/atmosphere/extras/ssh/id_rsa
cp $SSH_PUB_KEY /opt/dev/atmosphere/extras/ssh/id_rsa.pub
echo -e "Host *\n\tIdentityFile /opt/dev/atmosphere/extras/ssh/id_rsa\n\tStrictHostKeyChecking no\n\tUserKnownHostsFile=/dev/null" >> ~/.ssh/config

# Setup instance deploy automation
cp $ANSIBLE_HOSTS_FILE /opt/dev/atmosphere-ansible/ansible/hosts
cp -r $ANSIBLE_GROUP_VARS_FOLDER /opt/dev/atmosphere-ansible/ansible/group_vars

# Copy ini files
cp $SECRETS_DIR/inis/atmosphere.ini /opt/dev/atmosphere/variables.ini
cp $SECRETS_DIR/inis/atmosphere-ansible.ini /opt/dev/atmosphere-ansible/variables.ini
/opt/env/atmo/bin/python /opt/dev/atmosphere/configure
/opt/env/atmo/bin/python /opt/dev/atmosphere-ansible/configure

# Start services
service redis-server start
service celerybeat start
service celeryd start

# Wait for DB to be active
echo "Waiting for postgres..."
while ! nc -z postgres 5432; do sleep 5; done

# Finish Django DB setup
mkdir /opt/dev/atmosphere/static
$MANAGE_CMD collectstatic --noinput --settings=atmosphere.settings --pythonpath=/opt/dev/atmosphere
$MANAGE_CMD migrate --noinput --settings=atmosphere.settings --pythonpath=/opt/dev/atmosphere
$MANAGE_CMD loaddata --settings=atmosphere.settings --pythonpath=/opt/dev/atmosphere /opt/dev/atmosphere/core/fixtures/provider.json
$MANAGE_CMD loaddata --settings=atmosphere.settings --pythonpath=/opt/dev/atmosphere /opt/dev/atmosphere/core/fixtures/quota.json
$MANAGE_CMD loaddata --settings=atmosphere.settings --pythonpath=/opt/dev/atmosphere /opt/dev/atmosphere/core/fixtures/pattern_match.json
$MANAGE_CMD loaddata --settings=atmosphere.settings --pythonpath=/opt/dev/atmosphere /opt/dev/atmosphere/core/fixtures/boot_script.json
$MANAGE_CMD createcachetable --settings=atmosphere.settings --pythonpath=/opt/dev/atmosphere atmosphere_cache_requests

chmod 600 /opt/dev/atmosphere/extras/ssh/id_rsa
sudo su -l www-data -s /bin/bash -c "UWSGI_DEB_CONFNAMESPACE=app UWSGI_DEB_CONFNAME=atmosphere /opt/env/atmo/bin/uwsgi --ini /usr/share/uwsgi/conf/default.ini --ini /etc/uwsgi/apps-enabled/atmosphere.ini"
