test -z "$RJPCONFIGCHECKED" && {
  echo "Config not verified ($BASH_SOURCE)"
  exit 1
}

importPARAM message ".*";
test -n "$message" && echo "message: $message"

echo "Pong"
