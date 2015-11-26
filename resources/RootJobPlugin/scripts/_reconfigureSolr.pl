#!/usr/bin/perl -wT
# This script will create a new configuration for solr
# and prints it to STDOUT.
# It expects to be run in the solr directory.

my $cores = '';

@files = <*>;
foreach my $file (@files) {
  next if $file eq '^_' || $file eq 'conf' || $file =~ m/disabled/ || $file =~ m/backup/;
  next if not -d $file;

  $cores .= "    <core name=\"$file\" instanceDir=\"$file\" />\n";
}

print <<CONF
<?xml version="1.0" encoding="UTF-8" ?>
<solr persistent="false" sharedLib="lib">
  <cores adminPath="/admin/cores" sharedSchema="true">
$cores  </cores>
</solr>
CONF
