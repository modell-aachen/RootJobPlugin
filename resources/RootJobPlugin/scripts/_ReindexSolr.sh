test -z "$USESOLR" && {
  echo "Not using Solr according to USESOLR"
  return
}

test -z "$RJPCONFIGCHECKED" && {
  echo "Config not verified ($BASH_SOURCE)"
  exit 1
}

importPARAM wname "$VHOSTREGEX"
test -z $wname && wname=all

importPARAM MODE "[a-z]*"
test -z $MODE && MODE=full

solrcmd=$( echo $INDEXCMD | sed -e "s#%VIRTUALHOST%#$wname#g" -e "s#%MODE%#$MODE#g" )

echo "Reindexing $wname in mode $MODE..."
echo $solrcmd | sh
