# Docker Container for Atmosphere
from ubuntu:14.04

# Set environment
ENV CLANK_WORKSPACE /opt/dev/clank_workspace
SHELL ["/bin/bash", "-c"]

# Install dependencies with apt
RUN apt-get update
RUN apt-get install -y  \
    apt-transport-https \
    git                 \
    kmod                \
    libffi-dev          \
    libssl-dev          \
    python              \
    python-pip          \
    python-dev          \
    sudo

# Prep Clank git repo and virtualenv; install pip requirements
# RUN pip install --upgrade pip virtualenv
RUN pip install --upgrade pip==9.0.3 virtualenv
RUN mkdir -p $CLANK_WORKSPACE
RUN mkdir -p /root/.ssh
RUN git clone --depth 1 https://github.com/cyverse/clank.git $CLANK_WORKSPACE/clank;
RUN virtualenv $CLANK_WORKSPACE/clank_env
RUN source $CLANK_WORKSPACE/clank_env/bin/activate
RUN pip install -r $CLANK_WORKSPACE/clank/requirements.txt

# Create PID and log directories for uWSGI
RUN mkdir -p /run/uwsgi/app/troposphere
RUN chown -R www-data:www-data /run/uwsgi/app/
RUN mkdir /var/log/uwsgi && touch /var/log/uwsgi/troposphere.log
RUN chown -R www-data:www-data /var/log/uwsgi

# Run clank ansible
WORKDIR $CLANK_WORKSPACE/clank

# Run as much as possible before adding vars for faster rebuilds with new vars
RUN ansible-playbook playbooks/prepare_host.yml

RUN ansible-playbook playbooks/deploy_troposphere.yml \
    --tags=dependencies                               \
    --skip-tags=ssl

# Add variables files
ADD atmo-local $CLANK_WORKSPACE/

RUN ansible-playbook playbooks/deploy_troposphere.yml             \
    -e @$CLANK_WORKSPACE/clank_init/build_env/variables.yml@local \
    --tags=ssl

# Import args before cloning branch
ARG TROPO_REPO='cyverse'
ARG TROPO_BRANCH='master'

RUN ansible-playbook playbooks/deploy_troposphere.yml             \
    -e @$CLANK_WORKSPACE/clank_init/build_env/variables.yml@local \
    -e troposphere_github_repo=https://github.com/$TROPO_REPO/troposphere.git \
    -e troposphere_github_branch=$TROPO_BRANCH                    \
    --skip-tags=dependencies,database,manage-migrate

RUN ansible-playbook playbooks/post_deployment.yml                \
    -e @$CLANK_WORKSPACE/clank_init/build_env/variables.yml@local

RUN sed -i 's/^DATABASE_HOST = ""$/DATABASE_HOST = "postgres"/' /opt/dev/troposphere/variables.ini
RUN /opt/env/troposphere/bin/python /opt/dev/troposphere/configure

ADD django_manage.yml $CLANK_WORKSPACE/clank/playbooks/django_manage.yml

# Add entrypoint script
ADD entrypoint.sh /root/entrypoint.sh
RUN chmod +x /root/entrypoint.sh
ENTRYPOINT ["/root/entrypoint.sh"]
