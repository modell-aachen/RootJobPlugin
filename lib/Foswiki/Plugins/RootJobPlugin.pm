# See bottom of file for default license and copyright information

=begin TML

---+ package Foswiki::Plugins::RootJobPlugin

=cut


package Foswiki::Plugins::RootJobPlugin;

# Always use strict to enforce variable scoping
use strict;
use warnings;

use Foswiki::Func    ();    # The plugins API
use Foswiki::Plugins ();    # For the API version

our $VERSION = '$Rev: 20120217 (2012-02-17) $';

our $RELEASE = '0.2.2';

our $SHORTDESCRIPTION = 'Create virtual hosts using VirtualHostingContrib.';

our $NO_PREFS_IN_TOPIC = 1;

=begin TML

---++ initPlugin($topic, $web, $user) -> $boolean
   * =$topic= - the name of the topic in the current CGI query
   * =$web= - the name of the web in the current CGI query
   * =$user= - the login name of the user
   * =$installWeb= - the name of the web the plugin topic is in
     (usually the same as =$Foswiki::cfg{SystemWebName}=)

=cut

sub initPlugin {
    my ( $topic, $web, $user, $installWeb ) = @_;

    # check for Plugins.pm versions
    if ( $Foswiki::Plugins::VERSION < 2.0 ) {
        Foswiki::Func::writeWarning( 'Version mismatch between ',
            __PACKAGE__, ' and Plugins.pm' );
        return 0;
    }

    Foswiki::Func::registerRESTHandler( 'WikiCommand', \&WikiCommand );


# Plugin correctly initialized
return 1;
}

sub WriteCommand {
    my ( $command, $username, $template ) = @_;

    $command =~ m#^([a-z0-9\._.\-]+)$# or return "The name of your wiki \"$command\" may only contain (lower case) letters and numbers."; # XXX
    $command = $1;

    my $cmdDir = $Foswiki::cfg{Extensions}{RootJobPlugin}{cmdDir} || return "Please set cmdDir in configure!";

    # check if already issued
    if (-e "$cmdDir/$command") {
        return "The command has already been issued, it will be processed soon.";
    }

    my $time = localtime(time);

    open my $wfile, ">", "$cmdDir/$command" || return "Error while creating file in $cmdDir, please check your configuration.";
    print $wfile "Request for $command issued by $username at $time.\n   * Command=$command" || return "Error while writing to $cmdDir/$command.";
    print $wfile "\n   * Template=$template" if ($template);
    close $wfile || return "Error while closing $cmdDir/$command.";

    return "Command $command issued.";
}

sub WikiCommand {
    my ( $session, $subject, $verb, $response ) = @_;

    # Username and rights
    if (Foswiki::Func::isGuest()) {
        return "This is not for guests!";
    }
    my $username = Foswiki::Func::getWikiName( undef );
    my $permWeb = $Foswiki::cfg{Extensions}{RootJobPlugin}{PermissionWeb} || 'System';
    my $permTopic = $Foswiki::cfg{Extensions}{RootJobPlugin}{PermissionTopic} || 'RootJobPlugin';
    if (not Foswiki::Func::checkAccessPermission('CHANGE', $username, '', $permTopic, $permWeb, undef )) {
        return "$username, you are not allowed to create wikis! Write permission for $permWeb/$permTopic required!";
    }

    # extract command
    my $param = $session->{request}->{param};

    my $command = $param->{command}[0];
    if(!$command) {
        return "Illegal rest-call, no command found!";
    }
    my $unique = $param->{wname}[0]; # XXX
    if(!$unique) {
        return "No unique!";
    }

    my $time = localtime(time);

    my $filename = $command."_$unique.cmd";
    $filename =~ m#^([a-zA-Z0-9\._.\-]+)$# or return "The command \"$command\" ($filename) may only contain letters and numbers."; # XXX
    $filename = $1;

    my $cmdDir = $Foswiki::cfg{Extensions}{RootJobPlugin}{cmdDir} || return "Please set cmdDir in configure!";

#   # check if already issued
#   if (-e "$cmdDir/$filename") {
#     return "The command has already been issued, it will be processed soon.";
#   }


    open my $wfile, ">", "$cmdDir/$filename" || return "Error while creating file $cmdDir/$filename, please check your configuration.";
    print $wfile "Command '$command' issued by $username at $time.\n   * user=$username\n   * time=$time" || return "Error while writing to $cmdDir/$command.";
    foreach my $eachparam (keys %$param) {
        print $wfile "\n   * $eachparam=$param->{$eachparam}[0]";
    }

    return "Command $command issued ($filename)"; 
}

1;

__END__
Foswiki - The Free and Open Source Wiki, http://foswiki.org/

Author: StephanOsthold

Copyright (C) 2008-2011 Foswiki Contributors. Foswiki Contributors
are listed in the AUTHORS file in the root of this distribution.
NOTE: Please extend that file, not this notice.

This program is free software; you can redistribute it and/or
modify it under the terms of the GNU General Public License
as published by the Free Software Foundation; either version 2
of the License, or (at your option) any later version. For
more details read LICENSE in the root of this distribution.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

As per the GPL, removal of this notice is prohibited.
