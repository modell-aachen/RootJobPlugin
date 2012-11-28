test -z "$VHOST" && {
  echo "Please specify in configVHC.sh where VirtualHosts reside (VHOST)"
  exit 1
}
test -z "$DISABLED" && {
  echo "Please specify in configVHC.sh where disabled hosts reside (DISABLED)"
  exit 1
}
test "$USESOLR" = on && {
  test -d "$SOLR" || {
    echo "Solr home not found in $SOLR"
    exit 1
  }
  test -d $SOLR/_template || {
    echo "No $SOLR/_template found to create new Solr index"
    exit 1
  }
  test -e $SCRIPTDIR/createSolrConfig.pl || {
    echo "Could not find script createSolrConfig.pl to create Solr configuration"
    exit 1
  }
}
test -e $CORE/tools/virtualhosts-create.sh || {
  echo "Could not find virtualhosts-create.sh in $CORE/tools, is VirtualHostingContrib installed?"
  exit 1
}

export RJPVHCCONFIGCHECKED=1
