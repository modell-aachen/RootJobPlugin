test -z "$RJPCONFIGCHECKED" && {
  echo "Config not verified ($BASH_SOURCE)"
  exit 1
}

test -n "$TOUCHEDWEBCFG" -o -n "$TOUCHEDCFG" && {
  echo "Restarting webserver..."
  sh "$WEBCMD" $WEBOPTS
}
