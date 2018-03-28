# Atmosphere-Docker

Entire Atmosphere development environment in Docker Containers using Docker-Compose.

**Please note that this is a work in progress. It currently works to deploy a local Atmosphere setup, but more work is required to harness the full potential of Docker Compose. Create issues for any problems or feature requests.**

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
```

##### Optional
Add the following lines to use mock authentication with your username:
```
AUTH_ENABLE_MOCK: True
AUTH_MOCK_USER: "calvinmclean"
```

If you want to populate your database with production data, add these lines:
```
ATMO_DATA:
  LOAD_DATABASE: True
  SQL_DUMP_FILE: "{{ HOME }}/atmo_prod.sql"
```
And put the `SQL_DUMP_FILE` in `atmo-local` directory. **Make sure your containers are only locally accessible if you are doing this!!!**

##### Picking Atmosphere versions
Usually, you would specify the Atmosphere and Troposphere versions with:
```
atmosphere_github_repo: https://github.com/cyverse/atmosphere.git
atmosphere_github_branch: master
atmosphere_ansible_github_repo: https://github.com/cyverse/atmosphere-ansible.git
atmosphere_ansible_github_branch: master
troposphere_github_repo: https://github.com/cyverse/troposphere.git
troposphere_github_branch: master
```

I wanted to be able to specify the version with a build argument, so the variables above **will always be overridden by the default build arg in Docker, 'master', or the build arg specified when building the containers.**

Example:
```
docker-compose build --build-arg ATMO_BRANCH=v31 TROPO_BRANCH=v31 atmosphere troposphere
```

Please offer feedback on this choice because I am not sure I like the inconsistency that it brings into the project, but it allows quick and easy builds of specific versions if you are not messing with the vars in the atmo-local file.

## Containers/Services
- [Atmosphere](https://github.com/cyverse/atmosphere)
  - Entrypoint starts uWSGI, celeryd, redis-server, and postgresql
- [Troposphere](https://github.com/cyverse/troposphere)
  - Entrypoint starts uWSGI, and postgresql
- Nginx

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

Note: Use `./cleanup.sh --prune` to **ONLY** remove containers and volumes created by `docker-compose up`, without deleting other files

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
