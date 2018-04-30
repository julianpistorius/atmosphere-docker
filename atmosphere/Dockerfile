# Docker Container for Atmosphere
FROM ubuntu:14.04

# Set environment
ENV CLANK_WORKSPACE /opt/dev/clank_workspace
SHELL ["/bin/bash", "-c"]

# Install dependencies with apt
RUN apt-get update && \
    apt-get install --no-install-recommends -y  \
      apt-transport-https \
      build-essential \
      git \
      g++ \
      libffi-dev \
      libldap2-dev \
      libpq-dev \
      libsasl2-dev \
      libssl-dev \
      libxml2-dev \
      libxslt1-dev \
      make \
      openssl \
      python \
      python-dev \
      python-m2crypto \
      python-pip \
      python-psycopg2 \
      python-setuptools \
      python-tk \
      redis-server \
      ssh \
      sudo \
      swig \
      ufw \
      uwsgi \
      uwsgi-plugin-python \
      zlib1g-dev && \
    rm -rf /var/lib/apt/lists/*

# Prep Clank git repo and virtualenv; install pip requirements
RUN mkdir -p $CLANK_WORKSPACE /root/.ssh
RUN git clone --depth 1 https://github.com/cyverse/clank.git $CLANK_WORKSPACE/clank && \
    pip install --upgrade pip==9.0.3 virtualenv && \
    virtualenv $CLANK_WORKSPACE/clank_env

RUN source $CLANK_WORKSPACE/clank_env/bin/activate && \
    pip install --no-cache-dir -r $CLANK_WORKSPACE/clank/requirements.txt

# Create PID and log directories for uWSGI
RUN mkdir -p /run/uwsgi/app/atmosphere /var/log/uwsgi && \
    chown -R www-data:www-data /run/uwsgi/app/ /var/log/uwsgi && \
    touch /var/log/uwsgi/atmosphere.log

# Run Clank ansible
WORKDIR $CLANK_WORKSPACE/clank

# Import args before cloning branches
ARG ATMO_REPO='cyverse'
ARG ATMO_BRANCH='master'
ARG ANSIBLE_REPO='cyverse'
ARG ANSIBLE_BRANCH='master'

# Clone repos and pip install requirements
RUN mkdir /opt/env && \
    virtualenv /opt/env/atmosphere &&\
    ln -s /opt/env/atmosphere/ /opt/env/atmo
RUN git clone -b $ATMO_BRANCH https://github.com/$ATMO_REPO/atmosphere.git /opt/dev/atmosphere &&\
    git clone -b $ANSIBLE_BRANCH https://github.com/$ANSIBLE_REPO/atmosphere-ansible.git /opt/dev/atmosphere-ansible
RUN source /opt/env/atmo/bin/activate && pip install -r /opt/dev/atmosphere/requirements.txt

# Config logging
RUN mkdir /opt/dev/atmosphere/logs /var/tmp/django_cache/ && \
    touch /opt/dev/atmosphere/logs/atmosphere.log && \
    touch /opt/dev/atmosphere/logs/atmosphere_status.log

# Set webserver permissions
RUN chown -R www-data:www-data /opt/dev/atmosphere && \
    chmod g+rw /opt/dev/atmosphere && \
    chown -R www-data:www-data /var/tmp/django_cache/ && \
    chmod g+rw /var/tmp/django_cache/

COPY install_atmo.yml $CLANK_WORKSPACE/clank/playbooks/install_atmo.yml
RUN source $CLANK_WORKSPACE/clank_env/bin/activate && \
    ansible-playbook playbooks/install_atmo.yml

RUN apt-get autoremove -y && \
    rm -rf /var/lib/apt/lists/*

# Prepare entrypoint
COPY atmo_setup.yml $CLANK_WORKSPACE/clank/playbooks/atmo_setup.yml
COPY atmo_db_manage.yml $CLANK_WORKSPACE/clank/playbooks/atmo_db_manage.yml
COPY entrypoint.sh /root/entrypoint.sh
RUN chmod +x /root/entrypoint.sh
ENTRYPOINT ["/root/entrypoint.sh"]
