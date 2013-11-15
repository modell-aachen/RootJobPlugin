#!/usr/bin/perl -wT

# TODO Error handling
return unless $ARGV[0] =~ m#([A-Za-z0-9./]+)#;
my $vhostDir = $1;

chdir $vhostDir;
@files = <*>;
foreach my $file (@files) {
  next if $file eq '_template' || $file =~ m/disabled/;
  next if not -d $file;

  # print configuration
  print <<CONF;
\$HTTP["host"] == "$file" {
    server.name  = "$file"
    server.document-root = vhostsdir + "/" + server.name + "/html"
    include "qwiki-base.conf"
}
CONF
}
