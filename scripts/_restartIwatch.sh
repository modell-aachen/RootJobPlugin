test "$USEIWATCH" = "1" || exit 0;

test -z "$RJPCONFIGCHECKED" && {
  echo "Config not verified ($BASH_SOURCE)"
  exit 1
}

test -n "$USEIWATCH" && test -n "$TOUCHEDIWATCHCFG" -o -n "$TOUCHEDCFG" && {
  echo "Restarting iwatch..."
  bash "$IWATCHCMD" $IWATCHOPTS
}
