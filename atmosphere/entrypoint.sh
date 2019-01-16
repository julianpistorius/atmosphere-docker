#!/bin/bash
MANAGE_CMD="/opt/env/atmo/bin/python /opt/dev/atmosphere/manage.py"

source /opt/dev/clank_workspace/clank_env/bin/activate
cd /opt/dev/clank_workspace/clank

echo "ansible-playbook playbooks/atmo_setup.yml -e @$CLANK_WORKSPACE/clank_init/build_env/variables.yml@local"
ansible-playbook playbooks/atmo_setup.yml -e @$CLANK_WORKSPACE/clank_init/build_env/variables.yml@local

cp /opt/inis/atmosphere.ini /opt/dev/atmosphere/variables.ini
cp /opt/inis/atmosphere-ansible.ini /opt/dev/atmosphere-ansible/variables.ini
/opt/env/atmo/bin/python /opt/dev/atmosphere/configure
/opt/env/atmo/bin/python /opt/dev/atmosphere-ansible/configure

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
