#!/bin/bash
# Minecraft service that starts the minecraft server in a tmux session

MC_HOME="/var/minecraft"

TMUX_SOCKET="minecraft"
TMUX_SESSION="minecraft"

is_server_running() {
	tmux -L $TMUX_SOCKET has-session -t $TMUX_SESSION > /dev/null 2>&1
	return $?
}

mc_command() {
	cmd="$1"
	tmux -L $TMUX_SOCKET send-keys -t $TMUX_SESSION.0 "$cmd" ENTER
	return $?
}

start_server() {
	if is_server_running; then
		echo "Server already running"
		return 1
	fi
	echo "Starting minecraft server in tmux session"
	tmux -L $TMUX_SOCKET new-session -c $MC_HOME -s $TMUX_SESSION -d java -Xmx8G -Xms256M -jar spigot.jar
	return $?
}

stop_server() {
	if ! is_server_running; then
		echo "Server is not running!"
		return 1
	fi

	# Warn players
	echo "Warning players"
	mc_command "title @a times 3 14 3"
	for i in {10..1}; do
		mc_command "title @a subtitle {\"text\":\"in $i seconds\",\"color\":\"gray\"}"
		mc_command "title @a title {\"text\":\"Sutting down\",\"color\":\"dark_red\"}"
		sleep 1
	done

	# Issue shutdown
	echo "Kicking players"
	mc_command "kickall"
	echo "Stopping server"
	mc_command "stop"
	if [ $? -ne 0 ]; then
		echo "Failed to send stop command to server"
		return 1
	fi

	# Wait for server to stop
	wait=0
	while is_server_running; do
		sleep 1

		wait=$((wait+1))
		if [ $wait -gt 60 ]; then
			echo "Could not stop server, timeout"
			return 1
		fi
	done

	return 0
}

reload_server() {
	tmux -L $TMUX_SOCKET send-keys -t $TMUX_SESSION.0 "reload" ENTER
	return $?
}

attach_session() {
	if ! is_server_running; then
		echo "Cannot attach to server session, server not running"
		return 1
	fi

	tmux -L $TMUX_SOCKET attach-session -t $TMUX_SESSION
	return 0
}

case "$1" in
start)
	start_server
	exit $?
	;;
stop)
	stop_server
	exit $?
	;;
reload)
	reload_server
	exit $?
	;;
attach)
	attach_session
	exit $?
	;;
*)
	echo "Usage: ${0} {start|stop|reload|attach}"
	exit 2
	;;
esac

