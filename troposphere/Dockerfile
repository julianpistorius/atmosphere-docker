# Docker Container for Troposphere
FROM ubuntu:14.04

# Set environment
ENV CLANK_WORKSPACE /opt/dev/clank_workspace
SHELL ["/bin/bash", "-c"]

# Install dependencies with apt
RUN apt-get update && \
    apt-get install --no-install-recommends -y curl && \
    curl -skL https://deb.nodesource.com/setup_8.x | bash -
RUN apt-get update && \
    apt-get install --no-install-recommends -y \
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
      nginx \
      nodejs \
      openssl \
      python \
      python-dev \
      python-m2crypto \
      python-pip \
      python-psycopg2 \
      python-setuptools \
      python-tk \
      sudo \
      swig \
      ufw \
      uwsgi \
      uwsgi-plugin-python \
      zlib1g-dev && \
    rm -rf /var/lib/apt/lists/*

ARG CLANK_REPO
ARG CLANK_BRANCH

# Prep Clank git repo and virtualenv; install pip requirements
RUN mkdir -p $CLANK_WORKSPACE /root/.ssh
RUN git clone --depth 1 -b $CLANK_BRANCH https://github.com/$CLANK_REPO/clank.git $CLANK_WORKSPACE/clank && \
    pip install --upgrade pip==9.0.3 virtualenv && \
    virtualenv $CLANK_WORKSPACE/clank_env

RUN source $CLANK_WORKSPACE/clank_env/bin/activate && \
    pip install --no-cache-dir -r $CLANK_WORKSPACE/clank/requirements.txt

# Create PID and log directories for uWSGI
RUN mkdir -p /run/uwsgi/app/troposphere /var/log/uwsgi && \
    chown -R www-data:www-data /run/uwsgi/app/ /var/log/uwsgi && \
    touch /var/log/uwsgi/troposphere.log

# Run Clank ansible
WORKDIR $CLANK_WORKSPACE/clank

# Import args before cloning branch
ARG TROPO_REPO
ARG TROPO_BRANCH

# Clone repos and pip install requirements
RUN mkdir /opt/env && \
    virtualenv /opt/env/troposphere
RUN git clone -b $TROPO_BRANCH https://github.com/$TROPO_REPO/troposphere.git /opt/dev/troposphere
RUN source /opt/env/troposphere/bin/activate && pip install -r /opt/dev/troposphere/requirements.txt

# Config logging
RUN mkdir /var/tmp/django_cache/ && \
    touch /opt/dev/troposphere/logs/troposphere.log

# Set webserver permissions
RUN chown -R www-data:www-data /opt/dev/troposphere && \
    chmod g+rw /opt/dev/troposphere && \
    chown -R www-data:www-data /var/tmp/django_cache/ && \
    chmod g+rw /var/tmp/django_cache/

COPY install_tropo.yml $CLANK_WORKSPACE/clank/playbooks/install_tropo.yml
RUN source $CLANK_WORKSPACE/clank_env/bin/activate && \
    ansible-playbook playbooks/install_tropo.yml

    # Cleanup
RUN apt-get autoremove -y && \
    rm -rf /var/lib/apt/lists/*
RUN rm /etc/nginx/sites-enabled/default


# Prepare entrypoint
COPY tropo_setup.yml $CLANK_WORKSPACE/clank/playbooks/tropo_setup.yml
COPY tropo_db_manage.yml $CLANK_WORKSPACE/clank/playbooks/tropo_db_manage.yml
COPY configure_nginx.yml $CLANK_WORKSPACE/clank/playbooks/configure_nginx.yml
COPY entrypoint.sh /root/entrypoint.sh
RUN chmod +x /root/entrypoint.sh
ENTRYPOINT ["/root/entrypoint.sh"]
