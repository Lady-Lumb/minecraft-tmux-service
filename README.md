# Project Zomboid tmux service

With these files a minecraft server can be started in a tmux session via systemd. This allows to easily start and stop the server while still being able to connect to its console.

## Requirements

`tmux` needs to be installed on the system.

The script was written for the following settings. If any of those don't match your system, you might have to change the script accordingly.
* A user named `steam` exists on the system. This user will run the minecraft server.
* The users home directory is `/home/steam`
* The server files and its working directory are in the home directory (`/home/steam/pzserver`)


## Installation

* Place the `pzserver-service.sh` file in the server directory of `/home/steam/pzserver`.
* Change the owner of the script to `steam` and make sure it is executable.
* Copy the `pzserver.service` file to `/etc/systemd/system/` and reload the systemd daemon
```
sudo systemctl daemon-reload
```

## Usage

You can now start the server via systemd:
```
systemctl start pzserver
```

To attach to the tmux session that the service is running in, run:
```
/home/steam/pzserver/pzserver-service.sh attach
```
