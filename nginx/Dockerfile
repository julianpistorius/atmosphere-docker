# Docker Container for Nginx
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
    nginx \
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

# Add variables files
ADD atmo-local $CLANK_WORKSPACE/
ADD configure_nginx.yml $CLANK_WORKSPACE/clank/playbooks/configure_nginx.yml
# Run clank ansible
WORKDIR $CLANK_WORKSPACE/clank
RUN ansible-playbook -e @$CLANK_WORKSPACE/clank_init/build_env/variables.yml@local playbooks/configure_nginx.yml
RUN rm /etc/nginx/sites-enabled/default

EXPOSE 443
CMD ["nginx", "-g", "daemon off;"]
