# Docker Container for Atmosphere
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

# Prep Clank git repo and virtualenv; install pip requirements
RUN mkdir -p $CLANK_WORKSPACE /root/.ssh
RUN git clone --depth 1 https://github.com/cyverse/clank.git $CLANK_WORKSPACE/clank && \
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

# Add variables files
COPY atmo-local $CLANK_WORKSPACE/

# Import args before cloning branch
ARG TROPO_REPO='cyverse'
ARG TROPO_BRANCH='master'

RUN source $CLANK_WORKSPACE/clank_env/bin/activate && \
    ansible-playbook playbooks/deploy_troposphere.yml             \
    -e @$CLANK_WORKSPACE/clank_init/build_env/variables.yml@local \
    -e troposphere_github_repo=https://github.com/$TROPO_REPO/troposphere.git \
    -e troposphere_github_branch=$TROPO_BRANCH                    \
    --skip-tags=dependencies,database,manage-collectstatic,manage-migrate,theme,npm,generate-config

RUN apt-get autoremove -y && \
    rm -rf /var/lib/apt/lists/* && \
    rm -rf $CLANK_WORKSPACE/atmo-local

# Prepare entrypoint
COPY tropo_setup.yml $CLANK_WORKSPACE/clank/playbooks/tropo_setup.yml
COPY tropo_db_manage.yml $CLANK_WORKSPACE/clank/playbooks/tropo_db_manage.yml
COPY tropo_final.yml $CLANK_WORKSPACE/clank/playbooks/tropo_final.yml
COPY entrypoint.sh /root/entrypoint.sh
RUN chmod +x /root/entrypoint.sh
ENTRYPOINT ["/root/entrypoint.sh"]
