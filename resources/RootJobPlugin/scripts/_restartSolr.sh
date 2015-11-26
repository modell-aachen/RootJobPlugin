test "$USESOLR" = "1" || exit 0;

test -z "$RJPCONFIGCHECKED" && {
  echo "Config not verified ($BASH_SOURCE)"
  exit 1
}

test -n "$USESOLR" && test -n "$TOUCHEDSOLRCFG" -o -n "$TOUCHEDCFG" && {
  echo "Restarting solr..."
  sh "$SOLRCMD" $SOLROPTS
}
