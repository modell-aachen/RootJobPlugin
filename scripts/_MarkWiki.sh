test -z "$RJPCONFIGCHECKED" -o -z "$RJPVHCCONFIGCHECKED" && {
    echo "Config not checked ($BASH_SOURCE)!"
    exit 1
}

importPARAM wname "$VHOSTREGEX"
test -z "$wname" && { echo "Please specify wname!"; exit 1; }

test -e "$VHOST/$wname" || { echo "Wiki $wname does not seem to exist!"; exit 1; }

importPARAM mark "[a-zA-Z_.]*"
test -z "$mark" && { echo "Please specify mark!"; exit 1; }

touch "$VHOST/$wname/$mark"
