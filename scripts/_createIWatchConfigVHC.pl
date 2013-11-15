#!/usr/bin/perl -wT

### Config
my $core = $ENV{CORE} || die "Please set CORE your core dir";
my $vhost = $ENV{VHOST} || die "Please set VHOST to your virtual hosts dir";

# Command to be executed, %VIRTUALHOST% will be replaced with actual virtual host
my $exec = $ENV{INDEXCMD} || die "Please specify index command in INDEXCMD";

my $cmddir = $ENV{CMDDIR} || die "Please specify the directory to be watched for new commands";
my $scriptdir = $ENV{SCRIPTDIR} || die "Please specify where (WikiCreatorPlugin) scripts reside";
my $mail = $ENV{WRPEMAIL} || "root\@localhost";
### /Config

my $hosts = '';

@files = <*>;
foreach my $file (@files) {
  next if $file =~ m/'^_'/ || $file eq 'conf' || $file =~ m/disabled/;
  next if not -d $file;

  my $host = "      <path type=\"recursive\" events=\"close_write\" alert=\"off\" syslog=\"off\" filter=\"\\.txt\$\" exec=\"$exec > /dev/null \" >$vhost/%VIRTUALHOST%/data</path>\n";

  
  $host =~ s#%VIRTUALHOST%#$file#g;
  $host =~ s#%MODE%#delta#g;
  $hosts .= $host;
}

print <<CONF;
  <watchlist>
    <title>Wikis</title>
    <contactpoint email="$mail" name="Administrator"/>
$hosts  </watchlist>
CONF
