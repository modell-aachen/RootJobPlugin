test -z "$RJPCONFIGCHECKED" -o -z "$RJPVHCCONFIGCHECKED" && {
  echo "Config not verified"
  exit 1
}

test -n "$USEIWATCH" && test -n "$TOUCHEDIWATCHCFG" -o -n "$TOUCHEDCFG" && {
  echo "Restarting iwatch..."
  sh $IWATCHCMD $IWATCHOPTS
}
