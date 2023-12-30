# Architecture

Docker is designed as s client-server architecture, so a daemon service
`dockerd` is runing background, listening on port `2379` and
`sock://run/docker.sock`.

All the docker daily work such `docker build`, `docker pull`, `docker push` etc
are accomplished by the `dockerd` server.

Be aware of that docker client and docker server may be located in disk as a
single executable file.
