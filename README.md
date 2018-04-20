# Atmosphere-Docker

Entire Atmosphere development environment in Docker Containers using Docker-Compose.

**Please note that this is a work in progress. It currently works to deploy a local Atmosphere setup, but more work is required to harness the full potential of Docker Compose. Create issues for any problems or feature requests.**

**Also, take a look at the open issues to see what you can expect to go wrong**


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


## Quickstart
1. Copy `atmo-local` to the base of this directory and fill out necessary variables
1. `./setup.sh` to copy atmo-local to each container's build directory
1. `docker-compose build` to build all containers. This step will take a while the first time it is run, but will be quicker after that
1. `docker-compose up` to start all containers (use the `-d` option to start containers in the background)

Gracefully shut down containers with `Ctrl+c`. Press it again to kill containers.


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


##### Optional
Add the following lines to use mock authentication with your username:
```
AUTH_ENABLE_MOCK: True
AUTH_MOCK_USER: "calvinmclean"
```

If you want to populate your database with production data, follow the directions in the `atmo-local` repository to download a sanitary sql dump and put it in `atmo-local` directory. **Make sure your containers are only locally accessible if you are doing this!!!**

The database file will be picked up and used by the postgres container when you run `docker-compose up` after using `./setup.sh`


## Testing and development workflow
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

Now, you will probably want to rebuild on a new branch but you may not want to overwrite the existing image so you can easily jump back and forth.
When you build a container it is created with the name: `atmospheredocker_<service>:latest`. So when you rebuild, that image will be overwritten. The best solution to this is to change the tags on your existing images:
```
docker tag atmospheredocker_atmosphere:latest atmospheredocker_atmosphere:<new_tag>
docker tag atmospheredocker_troposphere:latest atmospheredocker_troposphere:<new_tag>
docker tag atmospheredocker_nginx:latest atmospheredocker_nginx:<new_tag>
```

However, a simpler solution is to rebuild the Docker-Compose project using a different project name:
```
docker-compose -p <other_name> build
```

Another situation is that you want to rebuild from a different branch and you want to save the exact state of your existing container you can use `docker commit` to create an image from that container:
**Note: If you just want to preserve the state of your database, this is no longer necessary as long as you don't delete the postgres container.** Just delete the other containers and re-run `docker-compose up`.
```
docker commit atmospheredocker_atmosphere_1 atmospheredocker_atmosphere:<tag>
```

However, what about the volumes and how does this compose? Well, it doesn't. So I created a script to commit the images and copy the volumes, and added an alternate docker-compose file to run the backups. Run the following with or without docker-compose running:
```
./alt.sh
docker-compose -f docker-compose-alt.yml up
```

This creates:
  - image: `alt_atmo`
  - image: `alt_tropo`
  - image: `alt_nginx`
  - image: `alt_postgres`
  - container: `atmospheredocker_atmosphere-alt_1`
  - container: `atmospheredocker_troposphere-alt_1`
  - container: `atmospheredocker_nginx-alt_1`
  - container: `atmospheredocker_postgres-alt_1`
  - volume: `alt_env`
  - volume: `alt_sockets`
  - volume: `alt_tropo`

Use `./alt-cleanup.sh` to remove these containers, images, and volumes.


## Containers/Services
- [Atmosphere](https://github.com/cyverse/atmosphere)
  - Entrypoint starts uWSGI, celeryd, redis-server
- [Troposphere](https://github.com/cyverse/troposphere)
  - Entrypoint starts uWSGI
- [Guacamole & guacd](https://guacamole.apache.org/)
- Nginx
- [Postgres](https://hub.docker.com/_/postgres/)


## Guacamole
Guacamole and Guacd containers are included as well. The `./guacamole` directory mirrors the setup of a `$GUACAMOLE_HOME` and is shared with the container. You shouldn't have to make any changes here, but if you wish to change the secret key, make sure you do so in your atmo-local variables as well. Although we tell Atmosphere that Guacamole can be found at `http://guacamole:8080/guacamole`, you can access it from your computer at `http://localhost:8080/guacamole`.

In order to get Guacamole working with `atmosphere-ansible`, you have to change `GUACAMOLE_SERVER_IP` in `group_vars/all` and the `guac_server` host in the hosts file.


## Logs
Logs from Atmosphere, nginx, and celery are located in `./logs`. It looks like this:
```
logs/
├── atmosphere
│   ├── atmosphere.log
│   ├── atmosphere_api.log
│   ├── atmosphere_auth.log
│   ├── atmosphere_deploy.log
│   ├── atmosphere_email.log
│   └── atmosphere_status.log
├── celery
│   ├── atmo
│   │   ├── atmosphere-deploy.log
│   │   ├── atmosphere-node.log
│   │   ├── beat.log
│   │   └── imaging.log
│   └── tropo
│       ├── atmosphere-deploy.log
│       ├── atmosphere-node.log
│       ├── beat.log
│       └── imaging.log
└── nginx
    ├── access.log
    └── error.log

5 directories, 16 files
```


## More info
`./setup.sh` -- copies `atmo-local/` into each of the sub-directories because each Dockerfile needs it

`./cleanup.sh` -- deletes `atmo-local/` from each sub-directory (but not the main one at `atmosphere-docker/atmo-local/`) and clears the log directory

Note: Use `./cleanup.sh --prune` to **ONLY** remove volumes created by `docker-compose up`, without deleting other files

`docker-compose up` -- creates and starts the whole stack

Or you can start individual services: `docker-compose up <SERVICE>`

Other useful `docker-compose` commands:
  - `docker-compose start <SERVICE>`
  - `docker-compose stop <SERVICE>`
  - `docker-compose restart <SERVICE>`
  - `docker-compose kill <SERVICE>`
  - `docker-compose build <SERVICE>`
  These can all be used without the <SERVICE> argument to perform the command on the whole stack

Inside the Dockerfiles, [Clank](https://github.com/cyverse/clank) is used to setup various parts of the stack. Note that the [`app-alter-kernel-for-imaging`](https://github.com/cyverse/clank/tree/master/roles/app-alter-kernel-for-imaging) is disabled because Docker does not allow kernel operations.


#### Variables
Define variables in the `atmo-local/` directory before running `./setup.sh`
