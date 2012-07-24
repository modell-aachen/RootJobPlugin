#!/bin/bash
# This script will create a new virtual host.
# Give the name of the new host als only parameter.
# Set the configuration below to your environment 

NEW=$1

test -z "$RJPCONFIGCHECKED" && {
  echo "Config not verified"
  exit 1
}

### Check parameters ###
test -z $NEW && {
  echo "Please specify the name of the new virtual host as only parameter"
  exit 1
}
test -z $VHOST && {
  echo "Please set VHOST to your virtual host directory"
  exit 1
}
test -z $CORE && {
  echo "Please set CORE to your core directory"
  exit 1
}

### Check files ###
test -d $VHOST/$NEW && {
  echo "Virtual Host $NEW already exits in $VHOST"
  exit 2
}
test -d $SOLR/_template || {
  echo "No template for solr found in $SOLR"
  exit 1
}

### Create Host ###
echo "Creating new host $NEW..."
cd $CORE/tools || {
  echo "Could not enter tools directory of core"
  exit 1
}
test -e virtualhosts-create-modac.sh && {
  # VHTEMPLATE must be environment-variable and may be empty
  ./virtualhosts-create-modac.sh $NEW $VHTEMPLATE || {
    echo "Error creating new host using virtualhosts-create-modac.sh"
    exit 2
  }
} || {
  ./virtualhosts-create.sh $NEW || {
    echo "Error creating new host"
    exit 2
  }
}

echo "Creating VirtualHost.cfg..."
cd $VHOST/$NEW 
test -e _template.cfg && {
  sed -e "s/%VIRTUALHOST%/$NEW/g" "_template.cfg" > "VirtualHost.cfg" && rm _template.cfg
} || {
  echo "No `pwd`/template.cfg found...not creating a VirtualHost.cfg"
}

echo "Creating new solr core for $NEW..."
cd $SOLR || {
  echo "Could not change into Solr directory $SOLR"
  exit 1
}
cp -p -r _template $NEW

