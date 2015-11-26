VHOST=$1

test "$USEAPACHEVHC" = "1" || exit 0;

test -z "$RJPCONFIGCHECKED" -o -z "$RJPVHCCONFIGCHECKED" -o -z "$APACHEVHCCONFIGCHECKED" && {
    echo "Config not checked ($BASH_SOURCE)!"
    exit 1
}

test -n $VHOST || { echo Please specify vhost!; exit 1; }

echo Deleting apache-config for $VHOST

rm "$APACHEHOSTS/$VHOST.conf"
