test -z "$RJPCONFIGCHECKED" -o -z "$RJPVHCCONFIGCHECKED" && {
  echo "Config not verified"
  exit 1
}

WIKINAME=`sed -n 's/^   \* wname=\([a-zA-Z_-]*\)/\1/p' <$CMDDIR/$FILE`

test -z "$WIKINAME" && {
  echo "Could not find wiki name!"
  return;
}

echo "Deleting $WIKINAME..."
test -d $VHOST/$WIKINAME || {
  echo "Wiki not found: $WIKINAME"
  return;
}

SUFFIX=_disabled
test -d $VHOST/${WIKINAME}_disabled && {
  SUFFIX=_disabled_`date +"%Y%m%d"`
  test -d $VHOST/${WIKINAME}${SUFFIX} && {
    SUFFIX=${SUFFIX}_`date +"%s"`
    test -d $VHOST/${WIKINAME}${SUFFIX} && {
      echo "Could not find a spot to move the old data to... please try again."
      return
    }
  }
}

# This unfortunately is a bit evil, since I'm first going to remove the data
# directories and then reconfigure the services using them.
# The proper way of course would be the other way around.
mv $VHOST/$WIKINAME $VHOST/${WIKINAME}${SUFFIX}
test -n "$USESOLR" -a -d "$SOLR/$WIKINAME" && {
  mv $SOLR/$WIKINAME $SOLR/${WIKINAME}${SUFFIX}
}

export TOUCHEDCFG=1
