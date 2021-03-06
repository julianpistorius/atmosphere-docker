# Docker Container for Atmosphere
FROM ubuntu:14.04

# Set environment
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

# Create PID and log directories for uWSGI
RUN mkdir -p /run/uwsgi/app/atmosphere /var/log/uwsgi && \
    chown -R www-data:www-data /run/uwsgi/app/ /var/log/uwsgi && \
    touch /var/log/uwsgi/atmosphere.log

# Import args before cloning branches
ARG ATMO_REPO
ARG ATMO_BRANCH
ARG ANSIBLE_REPO
ARG ANSIBLE_BRANCH

# Clone repos and pip install requirements
RUN mkdir /opt/env && \
    pip install --upgrade pip==9.0.3 virtualenv &&\
    virtualenv /opt/env/atmosphere &&\
    ln -s /opt/env/atmosphere/ /opt/env/atmo
RUN git clone -b $ATMO_BRANCH https://github.com/$ATMO_REPO/atmosphere.git /opt/dev/atmosphere && \
    git clone -b $ANSIBLE_BRANCH https://github.com/$ANSIBLE_REPO/atmosphere-ansible.git /opt/dev/atmosphere-ansible && \
    source /opt/env/atmo/bin/activate && \
    pip install -r /opt/dev/atmosphere/requirements.txt

# Set permissions on atmosphere
RUN chown -R www-data:www-data /opt/dev/atmosphere && \
    chmod g+rw /opt/dev/atmosphere

# Install initd files
COPY flower.initd /etc/init.d/flower
COPY celeryd.initd /etc/init.d/celeryd
COPY celerybeat.initd /etc/init.d/celerybeat
RUN chmod -R 755 /etc/init.d

# Setup uwsgi
RUN mkdir -p /etc/uwsgi/apps-available /etc/uwsgi/apps-enabled
COPY atmosphere.ini /etc/uwsgi/apps-available/
RUN ln -s /etc/uwsgi/apps-available/atmosphere.ini /etc/uwsgi/apps-enabled/atmosphere.ini

# Cleanup
RUN apt-get autoremove -y && \
    rm -rf /var/lib/apt/lists/*

# Prepare entrypoint
COPY web_shell_no_gateone.yml /opt/dev/atmosphere-ansible/ansible/playbooks/instance_deploy/41_shell_access.yml
COPY entrypoint.sh /root/entrypoint.sh
RUN chmod +x /root/entrypoint.sh
ENTRYPOINT ["/root/entrypoint.sh"]
