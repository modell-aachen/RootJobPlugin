#!/bin/bash
# This script will create the configuration for solr and iwatch.
# It expects the following environment variables
#    SOLR: path to solr home
#    SCRIPTDIR: directory where scripts reside

test -z "$RJPCONFIGCHECKED" -o -z "$RJPVHCCONFIGCHECKED" && {
  echo "Config not verified"
  exit 1
}

test -n "$USESOLR" && test -n "$TOUCHEDSOLRCFG" -o -n "$TOUCHEDCFG" && {
  echo "Creating config for Solr..."
  test -z "$SOLR" && {
    echo "Please set environment variable SOLR to solrs home"
    exit 1
  }
  cd $SOLR || {
    echo "Could not change into Solr directory $SOLR"
    exit 1
  }
  test -e solr.xml && {
    mv solr.xml solr.xml.bck
  }
  cd $VHOST
  $SCRIPTDIR/_reconfigureSolr.pl > $SOLR/solr.xml || {
    echo "Could not create new Solr config"
    test -e $SOLR/solr.xml.bck && {
      echo "...restoring from solr.xml.bck"
      mv $SOLR/solr.xml.bck $SOLR/solr.xml
    }
    exit 1
  }
}

