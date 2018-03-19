# Docker Container for Atmosphere
from ubuntu:14.04

# Set environment
ENV CLANK_WORKSPACE /opt/dev/clank_workspace
SHELL ["/bin/bash", "-c"]

# Install dependencies with apt
RUN apt-get update
RUN apt-get install -y \
    apt-transport-https \
    git \
    kmod \
    libffi-dev \
    libssl-dev \
    python \
    python-pip \
    python-dev \
    sudo

# Prep git repo and virtualenv; install pip requirements
RUN pip install --upgrade pip virtualenv
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

# Add variables files
ADD atmo-local $CLANK_WORKSPACE/
# Run clank ansible
WORKDIR $CLANK_WORKSPACE/clank
RUN ansible-playbook -e @$CLANK_WORKSPACE/clank_init/build_env/variables.yml@local playbooks/prepare_host.yml
RUN ansible-playbook -e @$CLANK_WORKSPACE/clank_init/build_env/variables.yml@local playbooks/deploy_troposphere.yml
RUN ansible-playbook -e @$CLANK_WORKSPACE/clank_init/build_env/variables.yml@local playbooks/post_deployment.yml

# Add entrypoint script
ADD entrypoint.sh /root/entrypoint.sh
RUN chmod +x /root/entrypoint.sh
ENTRYPOINT ["/root/entrypoint.sh"]
