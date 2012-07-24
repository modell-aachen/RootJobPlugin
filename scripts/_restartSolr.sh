test -z "$RJPCONFIGCHECKED" -o -z "$RJPVHCCONFIGCHECKED" && {
  echo "Config not verified"
  exit 1
}

test -n "$USESOLR" && test -n "$TOUCHEDSOLRCFG" -o -n "$TOUCHEDCFG" && {
  echo "Restarting solr..."
  sh $SOLRCMD $SOLROPTS
}
