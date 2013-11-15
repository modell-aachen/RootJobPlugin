test "$USEAPACHEVHC" = "1" || return

export APACHEHOSTS="/etc/apache/conf.d"	# The directory where the configuration for vhosts reside
