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

# Add variables files
ADD atmo-local $CLANK_WORKSPACE/

# Import args before cloning branches
ARG ATMO_REPO='cyverse'
ARG ATMO_BRANCH='master'
ARG ANSIBLE_REPO='cyverse'
ARG ANSIBLE_BRANCH='master'

RUN source $CLANK_WORKSPACE/clank_env/bin/activate && \
    ansible-playbook playbooks/deploy_atmosphere.yml              \
    -e @$CLANK_WORKSPACE/clank_init/build_env/variables.yml@local \
    -e atmosphere_ansible_github_repo=https://github.com/$ANSIBLE_REPO/atmosphere-ansible.git \
    -e atmosphere_github_repo=https://github.com/$ATMO_REPO/atmosphere.git \
    -e atmosphere_github_branch=$ATMO_BRANCH                      \
    -e atmosphere_ansible_github_branch=$ANSIBLE_BRANCH           \
    --skip-tags=kernel,dependencies,database,manage-collectstatic,manage-migrate,manage-load-tables

RUN sed -i 's/^DATABASE_HOST = ""$/DATABASE_HOST = "postgres"/' /opt/dev/atmosphere/variables.ini && \
    /opt/env/atmo/bin/python /opt/dev/atmosphere/configure

RUN apt-get autoremove -y && rm -rf /var/lib/apt/lists/*

# Prepare entrypoint
ADD atmo_setup.yml $CLANK_WORKSPACE/clank/playbooks/atmo_setup.yml
ADD atmo_db_manage.yml $CLANK_WORKSPACE/clank/playbooks/atmo_db_manage.yml
ADD entrypoint.sh /root/entrypoint.sh
RUN chmod +x /root/entrypoint.sh
ENTRYPOINT ["/root/entrypoint.sh"]
