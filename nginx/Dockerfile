# Docker Container for Nginx
FROM debian:jessie-slim

# Set environment
ENV CLANK_WORKSPACE /opt/dev/clank_workspace
SHELL ["/bin/bash", "-c"]

# Install dependencies with apt
RUN apt-get update && \
    apt-get install --no-install-recommends -y \
      apt-transport-https \
      git \
      libffi-dev \
      libssl-dev \
      nginx \
      python \
      python-pip \
      python-dev && \
    rm -rf /var/lib/apt/lists/*

# Prep Clank git repo and virtualenv; install pip requirements
RUN mkdir -p $CLANK_WORKSPACE /root/.ssh
RUN git clone --depth 1 https://github.com/cyverse/clank.git $CLANK_WORKSPACE/clank && \
    pip install --upgrade pip==9.0.3 virtualenv && \
    virtualenv $CLANK_WORKSPACE/clank_env

RUN source $CLANK_WORKSPACE/clank_env/bin/activate && \
    pip install --no-cache-dir -r $CLANK_WORKSPACE/clank/requirements.txt

# Add variables files
ADD atmo-local $CLANK_WORKSPACE/
ADD configure_nginx.yml $CLANK_WORKSPACE/clank/playbooks/configure_nginx.yml

# Run Clank ansible
WORKDIR $CLANK_WORKSPACE/clank
RUN cp $CLANK_WORKSPACE/clank/roles/tls-cert/vars/Ubuntu.yml $CLANK_WORKSPACE/clank/roles/tls-cert/vars/Debian.yml
RUN source $CLANK_WORKSPACE/clank_env/bin/activate && \
    ansible-playbook playbooks/configure_nginx.yml \
    -e @$CLANK_WORKSPACE/clank_init/build_env/variables.yml@local

# Cleanup
RUN rm /etc/nginx/sites-enabled/default && rm -rf $CLANK_WORKSPACE
RUN apt-get remove -y \
      apt-transport-https \
      git \
      python \
      python-pip \
      python-dev && \
    apt-get autoremove -y && \
    rm -rf /var/lib/apt/lists/*

EXPOSE 443
CMD ["nginx", "-g", "daemon off;"]
