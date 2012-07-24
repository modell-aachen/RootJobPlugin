test -z "$RJPCONFIGCHECKED" -o -z "$RJPVHCCONFIGCHECKED" && {
  echo "Config not verified"
  exit 1
}

FILE=$1

WIKINAME=`sed -n 's/^   \* wname=\([a-zA-Z_-]*\)/\1/p' <$CMDDIR/$FILE`
export VHTEMPLATE=`sed -n 's/^   \* template=\([a-zA-Z_-]*\)/\1/p' <$CMDDIR/$FILE`

test -z "$WIKINAME" && {
  echo "Could not find wikiname in command, please specify 'wname'."
  return
}

cd $SCRIPTDIR
sh ./_createNewHost.sh $WIKINAME

export TOUCHEDSOLRCFG=1
export TOUCHEDIWATCHCFG=1
export TOUCHEDWEBCFG=1
