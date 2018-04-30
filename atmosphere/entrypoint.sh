#!/bin/bash

echo "-------------------------------------------------------------------------"
echo "ENVIRONMENT:"
echo "ATMO_REPO: $ATMO_REPO"
echo "ATMO_BRANCH: $ATMO_BRANCH"
echo "ANSIBLE_REPO: $ANSIBLE_REPO"
echo "ANSIBLE_BRANCH: $ANSIBLE_BRANCH"
echo "-------------------------------------------------------------------------"

# Change branches if necessary
cd /opt/dev/atmosphere
if [[ -n $ATMO_REPO ]]; then
  echo "git remote add $ATMO_REPO https://github.com/$ATMO_REPO/atmosphere.git"
  git remote add $ATMO_REPO https://github.com/$ATMO_REPO/atmosphere.git

  echo "git fetch $ATMO_REPO"
  git fetch $ATMO_REPO
fi

if [[ -n $ATMO_BRANCH ]]; then
  echo "git checkout $ATMO_BRANCH"
  git checkout $ATMO_BRANCH
fi

cd /opt/dev/atmosphere-ansible
if [[ -n $ANSIBLE_REPO ]]; then
  echo "git remote add $ANSIBLE_REPO https://github.com/$ANSIBLE_REPO/atmosphere-ansible.git"
  git remote add $ANSIBLE_REPO https://github.com/$ANSIBLE_REPO/atmosphere-ansible.git

  echo "git fetch $ANSIBLE_REPO"
  git fetch $ANSIBLE_REPO
fi

if [[ -n $ANSIBLE_BRANCH ]]; then
  echo "git checkout $ANSIBLE_BRANCH"
  git checkout $ANSIBLE_BRANCH
fi

source /opt/dev/clank_workspace/clank_env/bin/activate
cd /opt/dev/clank_workspace/clank
echo "ansible-playbook playbooks/atmo_setup.yml -e @$CLANK_WORKSPACE/clank_init/build_env/variables.yml@local"
ansible-playbook playbooks/atmo_setup.yml -e @$CLANK_WORKSPACE/clank_init/build_env/variables.yml@local

# Start services
service redis-server start
service celerybeat start
service celeryd start

# Wait for postgres and run playbook until it works
sleep 30
source /opt/dev/clank_workspace/clank_env/bin/activate
cd /opt/dev/clank_workspace/clank
echo "ansible-playbook playbooks/atmo_db_manage.yml -e @$CLANK_WORKSPACE/clank_init/build_env/variables.yml@local"
ansible-playbook playbooks/atmo_db_manage.yml -e @$CLANK_WORKSPACE/clank_init/build_env/variables.yml@local
while [[ $? != 0 ]]; do
  sleep 15
  echo "ansible-playbook playbooks/atmo_db_manage.yml -e @$CLANK_WORKSPACE/clank_init/build_env/variables.yml@local"
  ansible-playbook playbooks/atmo_db_manage.yml -e @$CLANK_WORKSPACE/clank_init/build_env/variables.yml@local
done

chmod 600 /opt/dev/atmosphere/extras/ssh/id_rsa
sudo su -l www-data -s /bin/bash -c "UWSGI_DEB_CONFNAMESPACE=app UWSGI_DEB_CONFNAME=atmosphere /opt/env/atmo/bin/uwsgi --ini /usr/share/uwsgi/conf/default.ini --ini /etc/uwsgi/apps-enabled/atmosphere.ini"
