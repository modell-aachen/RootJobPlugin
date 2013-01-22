test -z "$RJPCONFIGCHECKED" -o -z "$RJPVHCCONFIGCHECKED" && {
  echo "Config not verified ($BASH_SOURCE)"
  exit 1
}

FILE=$1

importPARAM wname "$VHOSTREGEX"
importPARAM VHTEMPLATE "$VHOSTREGEX"

test -z "$wname" && {
  echo "Could not find wikiname in command, please specify 'wname'."
  return
}

cd "$SCRIPTDIR"
bash ./_createNewHost.sh "$wname"

cd "$SCRIPTDIR" && find . -name _CreateWiki_\*.sh -exec bash {} "$wname" \;

export TOUCHEDSOLRCFG=1
export TOUCHEDIWATCHCFG=1
export TOUCHEDWEBCFG=1
