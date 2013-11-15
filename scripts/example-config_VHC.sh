test "$USEVHC" = "1" || return

export VHOST="/var/www/wiki/vhosts"	# The directory of you virtual hosts
export VHOSTREGEX="[a-zA-Z_.0-9-]*"	# virtual hosts must match this regex
export DISABLED="/var/www/wiki/disabled"	# The directory of disabled virtual hosts
