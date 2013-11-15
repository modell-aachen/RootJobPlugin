test -z "$RJPCONFIGCHECKED" && {
  echo "Config not verified ($BASH_SOURCE)"
  exit 1
}

FILE=$1

importPARAM service "[a-zA-Z,_-]*"

test -z "$service" && {
  echo "Could not find services in command, please specify 'service'."
  return
}

echo "$service" | grep -q webserver && export TOUCHEDWEBCFG=1
echo "$service" | grep -q solr && export TOUCHEDSOLRCFG=1
echo "$service" | grep -q iwatch && export TOUCHEDIWATCHCFG=1
echo "$service" | grep -q all && export TOUCHEDCFG=1
