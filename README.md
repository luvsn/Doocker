# Doocker

_Doocker_ provides Docker-Compose images for various Odoo versions, allowing to run Odoo fully isolated inside Docker containers.

**! Warning !**

For testing purposes only, use at your risk.


## Features
- Fully isolated Odoo + PostgreSQL containers.
- Allows to run _from source_ versions enabling to modify Odoo's source code directly from inside the container.
- Supports custom addons.

**! Warning !**

Doocker currently does not support multiple Odoo containers running at the same time, as they will all share the same PostgreSQL container. 

## Supported versions
 - Odoo 17,16,15,14,13,12,11,10
 - Odoo 17src, 16src, 12src: _from source_ versions.

## Prerequisites
-  Docker installed


## Custom Addons
Add custom addons in the _extra-addons_ directory. 
They will automatically be loaded without needing to specify the path thanks to the mounted volume (see docker-compose.yml files).


## Build Doocker image

Custom _"Doocker"_ images (17src,16src,12,12src,11,10) must first be created for _docker compose_ if on a new machine or if the `Dockerfile` has been modified. 

Odoo 17,16,15,14,13 official images are directly pulled from Docker and therefore do not need to be built. Skip this for these versions. 


### Usage

    -v: version from which to create a Doocker image

Example: create _doocker:16src_ image:

`./build-docker.sh -v 16src`

Example: create _doocker:11_ image:

`./build-docker.sh -v 11`



## Run Docker-Compose instance

_Fresh_ means that a new instance will be generated with a new database and everything initialised. Use this for the first launch. 

An instance can later be launched with persistence to preserve data.

To erase the database and start fresh again (necessary when switching versions [for now]), use the _-f_ option.

### Usage

    - f: create containers with fresh database
    - v <version>: create containers for the given Odoo version 

### Fresh instance

Example: **latest** fresh instance (currently 17.0):

`./run-docker -f`

Example: version **16** fresh instance

`./run-docker -f -v 16`

Example: version **12 from source** fresh instance

`./run-docker -f -v 12src`

### Instance with persistence in volumes

Example: **latest** instance (with persistence):

`./run-docker`

Version **16** instance (with persistence):

`./run-docker -v 16`


### Doocker from source

Currently available versions from source: 17src, 16src, 12src.

Start the containers and let Odoo initialise the database:

`./run-docker -f -v 17src`

Start Visual Studio Code and install the 'Dev Containers' extension.
Hit Ctrl+Shift+P > Dev Containers: attach to running container.

Launch Bourne Again Shell (bash) instead of (sh):
`/bin/bash`

Two Python processes are running. Use `pgrep python` to find them:
 - One executing `launch-server.py` which should not be killed, otherwise the container will stop.
 - One running the actual server. This one can be killed using `kill 30` (12src), `kill 31` (16src,17src) or `./kill-server.sh`.

Once the server's killed, `launch-server.py` will hang and let the container run.
Start the server again from VS Code's terminal:

`./run-server.sh`

or by using alias command: `rs`

One can update a particular module using `./run-server.sh -u <module>`

Alternatively, one can use `sudo docker exec -it <id> /bin/bash` to access the container.

**! Warning !**

Any modification made to the code inside the container is lost when recreating the container!

### Functioning

When _docker compose_ starts a container, it executes the `entrypoint.sh` script in charge of setting up the system environment. 

The entrypoint executes the `wait-for-psql.py` Python script to check whether it is able to connect to the _postgresql_ container.

Once a connection with _postgresql_ is established, the entrypoint executes the `launch-server.py` Python script. This script checks whether Odoo is initialised, and if not, lets Odoo populate the database.

Once everything's ready, `launch-server.py` starts the server using the `run-server.sh` script and hangs, keeping the container alive. 

Calling the `run-server.sh` script allows to detach the execution of the server from `launch-server.py`, allowing to stop the server and restart it from inside the container. 







