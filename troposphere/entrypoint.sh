#!/bin/bash

echo "-------------------------------------------------------------------------"
echo "ENVIRONMENT:"
echo "TROPO_REPO: $TROPO_REPO"
echo "TROPO_BRANCH: $TROPO_BRANCH"
echo "-------------------------------------------------------------------------"

# Change branches if necessary
cd /opt/dev/troposphere
if [[ -n $TROPO_REPO ]]; then
  echo "git remote add $TROPO_REPO https://github.com/$TROPO_REPO/troposphere.git"
  git remote add $TROPO_REPO https://github.com/$TROPO_REPO/troposphere.git

  echo "git fetch $TROPO_REPO"
  git fetch $TROPO_REPO
fi

if [[ -n $TROPO_BRANCH ]]; then
  echo "git checkout $TROPO_BRANCH"
  git checkout $TROPO_BRANCH
fi

source /opt/dev/clank_workspace/clank_env/bin/activate
cd /opt/dev/clank_workspace/clank

echo "ansible-playbook playbooks/tropo_setup.yml -e @$CLANK_WORKSPACE/clank_init/build_env/variables.yml@local"
ansible-playbook playbooks/tropo_setup.yml -e @$CLANK_WORKSPACE/clank_init/build_env/variables.yml@local

echo "ansible-playbook playbooks/tropo_db_manage.yml -e @$CLANK_WORKSPACE/clank_init/build_env/variables.yml@local"
ansible-playbook playbooks/tropo_db_manage.yml -e @$CLANK_WORKSPACE/clank_init/build_env/variables.yml@local

echo "ansible-playbook playbooks/tropo_final.yml -e @$CLANK_WORKSPACE/clank_init/build_env/variables.yml@local"
ansible-playbook playbooks/tropo_final.yml -e @$CLANK_WORKSPACE/clank_init/build_env/variables.yml@local

sudo su -l www-data -s /bin/bash -c "UWSGI_DEB_CONFNAMESPACE=app UWSGI_DEB_CONFNAME=troposphere /opt/env/atmo/bin/uwsgi --ini /usr/share/uwsgi/conf/default.ini --ini /etc/uwsgi/apps-enabled/troposphere.ini"
