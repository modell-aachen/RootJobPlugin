test -z "$RJPCONFIGCHECKED" -o -z "$RJPVHCCONFIGCHECKED" && {
  echo "Config not verified"
  exit 1
}

test -z "$USESOLR" && return

WIKINAME=`sed -n 's/^   \* wname=\([a-zA-Z_-]*\)/\1/p' <$CMDDIR/$FILE`

echo "Reindexing $WIKINAME..."
sh $INDEXCMD
