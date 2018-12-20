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

cp /opt/inis/troposphere.ini /opt/dev/troposphere/variables.ini
/opt/env/troposphere/bin/python /opt/dev/troposphere/configure

echo "ansible-playbook playbooks/tropo_setup.yml -e @$CLANK_WORKSPACE/clank_init/build_env/variables.yml@local"
ansible-playbook playbooks/tropo_setup.yml -e @$CLANK_WORKSPACE/clank_init/build_env/variables.yml@local

echo "ansible-playbook playbooks/tropo_db_manage.yml -e @$CLANK_WORKSPACE/clank_init/build_env/variables.yml@local"
ansible-playbook playbooks/tropo_db_manage.yml -e @$CLANK_WORKSPACE/clank_init/build_env/variables.yml@local

mkdir /opt/dev/troposphere/troposphere/tropo-static
/opt/env/troposphere/bin/python /opt/dev/troposphere/manage.py collectstatic --noinput --settings=troposphere.settings --pythonpath=/opt/dev/troposphere
/opt/env/troposphere/bin/python /opt/dev/troposphere/manage.py migrate --noinput --settings=troposphere.settings --pythonpath=/opt/dev/troposphere

cd /opt/dev/troposphere
npm install --unsafe-perm
npm run build --production

sudo su -l www-data -s /bin/bash -c "UWSGI_DEB_CONFNAMESPACE=app UWSGI_DEB_CONFNAME=troposphere /opt/env/troposphere/bin/uwsgi --ini /usr/share/uwsgi/conf/default.ini --ini /etc/uwsgi/apps-enabled/troposphere.ini"
