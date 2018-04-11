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
RUN pip install --upgrade pip virtualenv
RUN mkdir -p $CLANK_WORKSPACE
RUN mkdir -p /root/.ssh
RUN git clone --depth 1 https://github.com/cyverse/clank.git $CLANK_WORKSPACE/clank;
RUN virtualenv $CLANK_WORKSPACE/clank_env
RUN source $CLANK_WORKSPACE/clank_env/bin/activate
RUN pip install -r $CLANK_WORKSPACE/clank/requirements.txt

# Create PID and log directories for uWSGI
RUN mkdir -p /run/uwsgi/app/atmosphere
RUN chown -R www-data:www-data /run/uwsgi/app/
RUN mkdir /var/log/uwsgi && touch /var/log/uwsgi/atmosphere.log
RUN chown -R www-data:www-data /var/log/uwsgi

# Run clank ansible
WORKDIR $CLANK_WORKSPACE/clank

# Run as much as possible before adding vars for faster rebuilds with new vars
RUN ansible-playbook playbooks/prepare_host.yml

RUN ansible-playbook playbooks/deploy_atmosphere.yml \
    --tags=dependencies                              \
    --skip-tags=ssl

# Add variables files
ADD atmo-local $CLANK_WORKSPACE/

RUN ansible-playbook playbooks/deploy_atmosphere.yml              \
    -e @$CLANK_WORKSPACE/clank_init/build_env/variables.yml@local \
    --tags=ssl

# Import args before cloning branches
ARG ATMO_REPO='cyverse'
ARG ATMO_BRANCH='master'
ARG ANSIBLE_REPO='cyverse'
ARG ANSIBLE_BRANCH='master'

RUN service postgresql start &&                                   \
    ansible-playbook playbooks/deploy_atmosphere.yml              \
    -e @$CLANK_WORKSPACE/clank_init/build_env/variables.yml@local \
    -e atmosphere_ansible_github_repo=https://github.com/$ANSIBLE_REPO/atmosphere-ansible.git \
    -e atmosphere_github_repo=https://github.com/$ATMO_REPO/atmosphere.git \
    -e atmosphere_github_branch=$ATMO_BRANCH                      \
    -e atmosphere_ansible_github_branch=$ANSIBLE_BRANCH           \
    --skip-tags=kernel,dependencies

RUN ansible-playbook playbooks/post_deployment.yml                \
    -e @$CLANK_WORKSPACE/clank_init/build_env/variables.yml@local

# Add entrypoint script
ADD entrypoint.sh /root/entrypoint.sh
RUN chmod +x /root/entrypoint.sh
ENTRYPOINT ["/root/entrypoint.sh"]
