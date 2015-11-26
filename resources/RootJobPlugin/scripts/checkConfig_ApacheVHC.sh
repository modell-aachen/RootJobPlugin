test "$USEAPACHEVHC" = "1" || return

test "$USEVHC" = "1" || {
  echo "You need to set USEVHC to 1 if you want to use ApacheVHC!"
  exit 1
}

test -z "$APACHEHOSTS" && {
  echo "Please specify in configApache.sh where VirtualHosts-Configs reside (APACHE)"
  exit 1
}
test -d "$APACHEHOSTS" || {
  echo "Virtual hosts config-directory not found in $APACHEHOSTS"
  exit 1
}
test -e "$SCRIPTDIR/apacheVHC.template" || {
  echo "Template for apache-configuration not found: $SCRIPTDIR/apacheVHC.template"
  exit 1
}

export APACHEVHCCONFIGCHECKED=1
