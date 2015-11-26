test -z "$RJPCONFIGCHECKED" -o -z "$RJPVHCCONFIGCHECKED" && {
  echo "Config not verified ($BASH_SOURCE)"
  exit 1
}

importPARAM srcwiki "$VHOSTREGEX";
importPARAM dstwiki "$VHOSTREGEX";
importPARAM webs "[a-zA-Z_0-9,\\s-]*";
webs=`echo "$webs" | sed -e "s#\s*,\s*# #g"`

test -z "$srcwiki" -o -z "$dstwiki" -o -z "$webs" && {
  echo "Parameters missig!"
  echo "srcwiki: $srcwiki"
  echo "dstwiki: $dstwiki"
  echo "webs: $webs"
  return
}

for web in $webs; do
    test -d "$VHOST/$srcwiki/data/$web" || {
        echo "Source-web does not exist in $srcwiki: $web"
        return
    }
    test -d "$VHOST/$dstwiki/data/$web" && {
        echo "Destination-web already exist in $dstwiki: $web"
        return
    }
done

for web in $webs; do
    echo "Copiing $web from $srcwiki to $dstwiki"
    cp -pR "$VHOST/$srcwiki/data/$web" "$VHOST/$dstwiki/data/"
    test -d "$VHOST/$srcwiki/pub/$web" && cp -pR "$VHOST/$srcwiki/pub/$web" "$VHOST/$dstwiki/pub/"
done

# XXX: Restart IWatch, or it'll miss the new webs
