# Atmosphere-Docker

Entire Atmosphere development environment in Docker Containers using Docker-Compose.

**Please note that this is a work in progress. It currently works to deploy a local Atmosphere setup, but more work is required to harness the full potential of Docker Compose. Create issues for any problems or feature requests.**

**Also, take a look at the open issues to see what you can expect to go wrong**


**Currently, Web Shell connections do not work because the Atmosphere container cannot SSH to the Guacamole container. There are a few ways to get around this that I haven't automated yet:**
```bash
# 1. Manually copy the SSH public key to the instance's authorized_keys
docker exec -ti atmosphere-docker_guacamole_1 bash
cat /guac_stuff/keys/<USERNAME>/id_rsa_guac.pub

# 2. Enable SSH on the Guacamole container
docker exec -ti atmosphere-docker_guacamole_1 bash
apt-get update && apt-get install ssh vim
service ssh start
mkdir /root/.ssh
vim /root/.ssh/authorized_keys # paste in the Atmosphere public key
# Then change the hosts file in atmosphere-ansible to use 'guacamole' as the Guacamole host
```



## Installing Docker
### macOS
To install Docker on macOS, follow [these instructions](https://store.docker.com/editions/community/docker-ce-desktop-mac). This includes Docker Compose.


### Ubuntu
To install Docker on Ubuntu, follow [these instructions](https://docs.docker.com/install/linux/docker-ce/ubuntu/#install-using-the-repository).
Then, install Docker Compose:
```
sudo curl -L https://github.com/docker/compose/releases/download/1.19.0/docker-compose-`uname -s`-`uname -m` -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
```


## Getting started
1. Copy `atmo-local` to the base of this directory and fill out necessary variables (**see atmo-local section below**)
1. `docker-compose build` to build all containers. This step will take a while the first time it is run, but will be quicker after that
1. `docker-compose up` to start all containers (use the `-d` option to start containers in the background)
    - During startup, the postgres container will load the `.sql` dump file if it exists, which takes a while. During this process, Atmosphere and Troposphere run Clank tasks that rely on the database so these will fail and re-run until the database is ready.
    - Optionally change repositories and branches by modifying the `options.env` file. See "Changing branches at runtime" below for more info.

Gracefully shut down containers with `Ctrl+c`. Press it again to kill containers.

Or kill all containers with `docker-compose kill`.

Delete all containers when you are done with `docker-compose rm`.

Delete all unattached volumes with `docker volume prune`.


## atmo-local

See atmo-local repository in GitLab for more information on setting up the atmo-local variables.


##### Required
Set these variables in `atmo-local/clank_init/build_env/variables.yml@local`
```
SERVER_NAME: "localhost"
HOME: /opt/dev/clank_workspace

GUACAMOLE_ENABLED: True
GUACAMOLE_SECRET_KEY: "so-secret"
GUACAMOLE_SERVER_URL: "http://guacamole:8080/guacamole"
```

Change all occurrences of `/vagrant` to `{{ HOME }}`.


##### Optional
Add the following lines to use mock authentication with your username:
```
AUTH_ENABLE_MOCK: True
AUTH_MOCK_USER: "calvinmclean"
```

If you want to populate your database with production data, follow the directions in the `atmo-local` repository to download a sanitary sql dump and put it in the `./postgres` directory. **Make sure your containers are only locally accessible if you are doing this!!!**

The database file will be picked up and used by the postgres container when you run `docker-compose up`.


## Testing and development workflow
Between rebuilds, you should run the following commands to clear existing containers and volumes:
```
docker-compose rm
docker volume prune -f
```

#### Changinig branches on the build
You will most likely want to use `atmosphere-docker` with branches other than `cyverse/master`.

Usually, you would specify the Atmosphere and Troposphere versions in the `atmo-local` variables file, but I wanted to be able to specify the version with a build argument for convenience, so the variables in the file **will always be overridden by the default build arg in Docker, 'master', or the build arg specified when building the containers.**

Available build-args and their defaults:

| ARG            | Default         | Service/Container  |
|:---------------|:---------------:|-------------------:|
| ATMO_REPO      | `cyverse`       | atmosphere         |
| ATMO_BRANCH    | `master`        | atmosphere         |
| ANSIBLE_REPO   | `cyverse`       | atmosphere         |
| ANSIBLE_BRANCH | `master`        | atmosphere         |
| TROPO_REPO     | `cyverse`       | troposphere        |
| TROPO_BRANCH   | `master`        | troposphere        |

Example:
```
docker-compose build --build-arg ATMO_BRANCH=v31 TROPO_BRANCH=v31 atmosphere troposphere
```

Please offer feedback on this choice because I am not sure I like the inconsistency that it causes, but it allows quick and easy builds of specific versions without messing with the vars in the atmo-local file.

#### Changing branches at runtime
**This feature is WIP so I am not yet sure if this works all the time, or only for branches with small differences.**

The same variables above are available as runtime environment variables. If they are filled out in `options.env`, the Atmosphere and Troposphere entrypoints will run uwsgi configure and django manage in order to use the new branches.


#### Preserving containers/images on rebuild
Now, you will probably want to rebuild on a new branch but you may not want to overwrite the existing image so you can easily jump back and forth.
When you build a container it is created with the name: `atmosphere-docker_<service>:latest`. So when you rebuild, that image will be overwritten. The best solution to this is to change the tags on your existing images:
```
docker tag atmosphere-docker_atmosphere:latest atmosphere-docker_atmosphere:<new_tag>
docker tag atmosphere-docker_troposphere:latest atmosphere-docker_troposphere:<new_tag>
docker tag atmosphere-docker_nginx:latest atmosphere-docker_nginx:<new_tag>
```

However, a simpler solution is to rebuild the Docker-Compose project using a different project name:
```
docker-compose -p <other_name> build
```

Another situation is that you want to rebuild from a different branch and you want to save the exact state of your existing container you can use `docker commit` to create an image from that container:
```
docker commit atmosphere-docker_atmosphere_1 atmosphere-docker_atmosphere:<tag>
```

Then, when you switch back to the committed image, just change the tag as shown above.

**Note: If you just want to preserve the state of your database, this is no longer necessary as long as you don't delete the postgres container.** Just delete the other containers and re-run `docker-compose up`.


## Containers/Services
- [Atmosphere](https://github.com/cyverse/atmosphere)
  - Entrypoint finishes Atmosphere setup and starts uWSGI, celeryd, redis-server
- [Troposphere](https://github.com/cyverse/troposphere)
  - Entrypoint finishes Troposphere setup and starts uWSGI
- [Guacamole & guacd](https://guacamole.apache.org/)
- Nginx
  - Entrypoint finishes Nginx setup and adds certs, then starts Nginx
- [Postgres](https://hub.docker.com/_/postgres/)


## Guacamole
Guacamole and Guacd containers are included as well. The `./guacamole` directory mirrors the setup of a `$GUACAMOLE_HOME` and is shared with the container. You shouldn't have to make any changes here, but if you wish to change the secret key, make sure you do so in your atmo-local variables as well. Although we tell Atmosphere that Guacamole can be found at `http://guacamole:8080/guacamole`, you can access it from your computer at `http://localhost:8080/guacamole`.

In order to get Guacamole working with `atmosphere-ansible`, you have to change `GUACAMOLE_SERVER_IP` in `group_vars/all` and the `guac_server` host in the hosts file.


## Logs
Logs from Atmosphere, Troposphere, Nginx, and Celery are located in `./logs`. It looks like this:
```
logs/
├── atmosphere
│   ├── atmosphere.log
│   ├── atmosphere_api.log
│   ├── atmosphere_auth.log
│   ├── atmosphere_deploy.log
│   ├── atmosphere_email.log
│   └── atmosphere_status.log
├── celery
│   └── atmo
│       ├── atmosphere-deploy.log
│       ├── atmosphere-fast.log
│       ├── atmosphere-node.log
│       ├── beat.log
│       ├── celery_periodic.log
│       ├── email.log
│       └── imaging.log
├── nginx
│   ├── access.log
│   └── error.log
└── troposphere
    └── troposphere.log

5 directories, 16 files
```
