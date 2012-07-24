test -z "$RJPCONFIGCHECKED" -o -z "$RJPVHCCONFIGCHECKED" && {
  echo "Config not verified"
  exit 1
}

FILE=`echo $1 | sed s#^.*/##g` # strip of preceeding directory stuff
echo "Processing $FILE"
# What needs to be done?
CMD=`sed -n 's/^   \* command=\([a-zA-Z_]*\)\s*$/\1/p' <$CMDDIR/$FILE`

test -z "$CMD" && {
  echo "No command found in $FILE"
  rm $CMDDIR/$FILE 
  return;
}

cd $SCRIPTDIR
test -e _$CMD.sh || { # XXX I check this twice...
  echo "Command _$CMD.sh not found!"
}
test -e _$CMD.sh && {
  echo "running command $CMD"
  source _$CMD.sh $FILE
}

rm $CMDDIR/$FILE 

