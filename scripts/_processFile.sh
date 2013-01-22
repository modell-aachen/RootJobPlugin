test -z "$RJPCONFIGCHECKED" && {
  echo "Config not verified ($BASH_SOURCE)"
  exit 1
}

FILE=`echo $1 | sed s#^.*/##g` # strip of preceeding directory stuff
echo "Processing $FILE"
# What needs to be done?
importPARAM command "[a-zA-Z_]*"
echo "command: $command"
importPARAM user ".*"
echo "user: $user"
importPARAM localtime ".*"
echo "Issued by $user at $localtime"

test -z "$command" && {
  echo "No command found in $FILE"
  rm $CMDDIR/$FILE 
  return;
}

cd "$SCRIPTDIR"
test -e "_$command.sh" || { # XXX I check this twice...
  echo "Command _$command.sh not found!"
}
test -e "_$command.sh" && {
  echo "running command $command"
  source "$SCRIPTDIR/_$command.sh" "$FILE"
}

echo "--- Command finished, removing $FILE ---"
rm $CMDDIR/$FILE

