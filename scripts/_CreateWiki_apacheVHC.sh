NEWHOST=$1

test "$USEAPACHEVHC" = "1" || exit 0;

test -z "$RJPCONFIGCHECKED" -o -z "$RJPVHCCONFIGCHECKED" -o -z "$APACHEVHCCONFIGCHECKED" && {
    echo "Config not checked ($BASH_SOURCE)!"
    exit 1
}

test -n $NEWHOST || { echo "Please specify new host!"; exit 1; }

echo Creating apache-config for $NEWHOST

sed -e "s#%VIRTUALHOST%#$NEWHOST#g" -e "s#%CORE%#$CORE#g" -e "s#%VHOST%#$VHOST#g" "$SCRIPTDIR/apacheVHC.template" > "$APACHEHOSTS/$NEWHOST.conf"
