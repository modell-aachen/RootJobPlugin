test "$USEVHC" = "1" || return

export VHOST="/var/www/wiki/vhost"	# The directory of you virtual hosts
export VHOSTREGEX="[a-zA-Z_-.]*"	# virtual hosts must match this regex
export DISABLED="/var/www/wiki/disabled"	# The directory of disabled virtual hosts
