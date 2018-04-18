#!/bin/bash

service redis-server start
service celerybeat start
service celeryd start
sleep 30
source /opt/dev/clank_workspace/clank_env/bin/activate && cd /opt/dev/clank_workspace/clank && ansible-playbook playbooks/django_manage.yml -e @$CLANK_WORKSPACE/clank_init/build_env/variables.yml@local
while [[ $? != 0 ]]; do
  sleep 15
  source /opt/dev/clank_workspace/clank_env/bin/activate && cd /opt/dev/clank_workspace/clank && ansible-playbook playbooks/django_manage.yml -e @$CLANK_WORKSPACE/clank_init/build_env/variables.yml@local
done
sudo su -l www-data -s /bin/bash -c "UWSGI_DEB_CONFNAMESPACE=app UWSGI_DEB_CONFNAME=atmosphere /opt/env/atmo/bin/uwsgi --ini /usr/share/uwsgi/conf/default.ini --ini /etc/uwsgi/apps-enabled/atmosphere.ini"
