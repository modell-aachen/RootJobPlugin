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

our $RELEASE = "1.1";
our $VERSION = "1.1";

our $SHORTDESCRIPTION = 'Manage your server with a frontend in your wiki.';
our $NO_PREFS_IN_TOPIC = 1;

use constant COMMAND => 0;
use constant ALLOWED => 1;
use constant OPTIONS => 2;
use constant CHECKED   => 3;

our $jobs;

sub initPlugin {
    my ( $topic, $web, $user, $installWeb ) = @_;

    # check for Plugins.pm versions
    if ( $Foswiki::Plugins::VERSION < 2.0 ) {
        Foswiki::Func::writeWarning( 'Version mismatch between ',
            __PACKAGE__, ' and Plugins.pm' );
        return 0;
    }

    Foswiki::Func::registerRESTHandler( 'WikiCommand', \&WikiCommand,
        authenticate => 1,
        validate => 0,
        http_allow => 'GET,POST'
    );

    Foswiki::Func::registerTagHandler( 'ROOTJOB', \&_RootJob );

    $jobs = {};

    # Plugin correctly initialized
    return 1;
}

sub WikiCommand {
    my ( $session, $subject, $verb, $response ) = @_;

    # Username and rights
    if (Foswiki::Func::isGuest()) {
        return "This is not for guests!";
    }

    my $username = Foswiki::Func::getWikiName( undef );

    # extract details
    my $param = $session->{request}->{param};
    my ($job, $jweb, $jtopic);
    { # scope
        my @jobparam = $param->{job};
        my @rjwebparam = $param->{rjweb};
        my @rjtopicparam = $param->{rjtopic};
        if( !(
                scalar @jobparam == 1
                && scalar @rjwebparam == 1
                && scalar @rjtopicparam == 1
            ))
        {
            return "Illegal rest-call!"; # XXX Message
        }
        $job = $jobparam[0]->[0]; # XXX Fuck perl
        $jweb = $rjwebparam[0]->[0];
        $jtopic = $rjtopicparam[0]->[0];
    }

    my $webtopic = "$jweb.$jtopic";
    my $allowed = $Foswiki::cfg{Extensions}{RootJobPlugin}{Jobs} || '';
    return "Not in allowed list: $webtopic" unless $allowed =~ m/(?:^|,)\s*\Q$webtopic\E\s*(?:$|,)/; # XXX Message, Maketext

    $jobs->{$webtopic} = _parseJobTopic($jweb, $jtopic) unless $jobs->{$webtopic};
    my $details = $jobs->{$webtopic}->{$job};
    return "Job '$job' not found!" unless $details; # XXX Message
    my $command = @$details[COMMAND];
    return "No command specified!" unless $command;

    my $allowedUsers = @$details[ALLOWED];
    return "You are not allowed to execute this job." unless _isAllowed($allowedUsers); # XXX

    # Check all fields and add to output
    my $out = '';
    my $columnref = @$details[OPTIONS];
    my $fields = ();
    foreach my $column (@$columnref) {
        my ($name, $type, $options, $check, $messages, $format) = @$column;
        my $value;
        next unless defined $type;
        if ($type =~ m/^(?:text|select|checkbox|radio)$/){
            my $formvaluearray = $param->{$name};
            unless ($formvaluearray && scalar @$formvaluearray) {
                next if $type eq 'checkbox'; # == nothing ticked
                return "Parameter missing: $name";
            }
            # check 'check' fields
            for (my $cindex = 0; $cindex < scalar @$check; $cindex++) {
                my $regex = qr/@$check[$cindex]/;
                foreach my $fv (@$formvaluearray) {
                    unless ($fv =~ $regex) {
                        my $error = "Parameter wrong: $name = '$fv'";
                        $error .= ", @$messages[$cindex]" if @$messages[$cindex];
                        return $error;
                    }
                }
            }

            my $k = 0;
            if ($type =~ m#select|checkbox|radio#) { 
                # check if values of select/checkbox/radio are among provided options from table
                unless( $options ) {
                    return "Options wrong for $name";
                }
                my $optionarray = _toOptionsArray($options);
                foreach my $fv (@$formvaluearray) {
                    my $ok;
                    foreach my $option (@$optionarray) {
                        $ok = 1 if $option->{value}[0] eq $fv;
                    }
                    return "Invalid value $name='$fv'" unless $ok;
                }
            }
            $value = join(',', @$formvaluearray);
        } elsif ($type eq 'wiki' || $type eq 'combine') {
            # replace $bla with fields
            $value = $options;
            $value =~ s#\$([a-zA-Z0-9_]+)#_replaceWithFields($1, $fields)#ge;

            # expand macros
            if ($type eq 'wiki') {
                $value = Foswiki::Func::decodeFormatTokens($value);
                $value = Foswiki::Func::expandCommonVariables($value, $jtopic, $jweb);
            }
        } elsif ($type eq 'label' || $type eq 'submit') {
            next;
        } else {
            return "Invalid type: $type";
        }
        # all checks ok, add to output and remember it for $wiki and $combine
        $out .= "\n   * $name=$value";
        $fields->{$name} = $value;
    }

    my $time = time;
    my $localtime = localtime($time);

    my $filename = time."_$command.cmd";

    $filename =~ m#^([a-zA-Z0-9\._.\-]+)$# or return "The command \"$command\" ($filename) may only contain letters and numbers."; # XXX
    $filename = $1;
    
    my $cmdDir = $Foswiki::cfg{Extensions}{RootJobPlugin}{cmdDir} || return "Please set cmdDir in configure!";
   
    # check if already issued
    if (-e "$cmdDir/$filename") {
        # XXX count up, or something
        return "The command has already been issued, please try again.";
    }
    
    open (my $wfile, ">", "$cmdDir/$filename") || return "Error while creating file $cmdDir/$filename, please check your configuration.";
    print $wfile "Command '$command' issued by $username at $localtime.\n   * command=$command\n   * user=$username\n   * localtime=$localtime\n   * time=$time$out\n" || return "Error while writing to $cmdDir/$command.";
    return "Command $command issued ($filename)"; 
}

sub _replaceWithFields {
    my ($id, $fields) = @_;
    my $value = $fields->{$id};
    return $value if defined $value;
    return "\$$id";
}

sub _parseJobTopic {
    my ($web, $topic) = @_;

    my ($meta, $text) = Foswiki::Func::readTopic($web, $topic);

    my $found = {};

    my $id;

    foreach my $line ( split(/\n/, $text) ) {
        if (!$id && $line =~ m/^\s*\|\s*\*RootJobPlugin\*\s*\|\s*\*(.*)\*\s*\|\s*$/) {
            $id = $1;
            $found->{$id} = ();
            my @o = ();
            $found->{$id}[OPTIONS] = \@o;
        } elsif ($id && $line =~ m/^\s*\|\s*(.*?)\s*\|\s*(.*?)\s*\|\s*$/) {
            my $name = $1;
            my $value = $2;
            if ($name eq 'allowed') {
                $found->{$id}[ALLOWED] = $value;
            }
            elsif ($name eq 'command') {
                $found->{$id}[COMMAND] = $value;
            }
            else {
                my ($type, $option, $check, $messages, $format);
                $check = [];
                $messages = [];
                if( $value =~ m#^\s*\$(text|checkbox|radio|select|extern|label|wiki|combine)(?:\s|,)# ) {
                    $type = $1;
                }
                if( $value =~ m#options="([^"]*)"# ) {
                    $option = _escape($1);
                }
                while( $value =~ m#check="([^"]*)"(?:\s+message="([^"]*)")?#g ) {
                    my $regex = $1;
                    my $message = $2;
                    push( @$check, _escape($regex) );
                    if (defined $message) {
                        $message = _escape($message);
                    } else {
                        $message = '';
                    }
                    push( @$messages, $message );
                }
                if( $value =~ m#format="([^"]*)"# ) {
                    $format = _escape($1);
                }
                my @array = ($name, $type, $option, $check, $messages, $format);
                my $ref = $found->{$id}[OPTIONS];
                push(@$ref, \@array);
            }
        } else {
            $id = undef;
        }
    }
    return $found;
}

sub _parseAttribs {
    my ($string) = @_;

    my $attribs = {};

    # parse attribs
    while ($string =~ m#([a-z]*)\s*=\s*'([^']*)'#g) {
        unless (defined $attribs->{$1}) {
            my @tmp = ();
            $attribs->{$1} = \@tmp;
        }
        my $ref = $attribs->{$1};
        push(@$ref, $2);
    }

    return ($attribs);
}

sub _toOptionsArray {
    my $parsedItems = {};
    my ($values) = @_;
    my @options = ();
    $values =~ s#^\s*|\s*$##g;
    foreach my $o (split(/\s*,\s*/, $values)) {
        if ($o =~ m#\s*\{\s*'([^'}]*)'([^}]+)\}#) {
            my @value = ($1);
            my $string = $2;
            my ($attribs) = _parseAttribs($string);
            $attribs->{value} = \@value;
            push(@options, $attribs);
        } elsif ($o =~ m#\s*{\s*item([^}]+)}#) {
            my $string = $1;
            my ($attribs) = _parseAttribs($string);
            push(@options, $attribs);
        } else {
            my @array = ($o);
            my $attribs = {value=>\@array};
            push(@options, $attribs);
        }
    }
    return \@options;
}

sub _RootJob {
    my($session, $params, $topic, $web, $topicObject) = @_;

    my $jweb = $params->{web} || $web;
    my $jtopic = $params->{topic} || $topic;
    my $job = $params->{_DEFAULT} || $params->{job} || '';

    my $webtopic = "$jweb.$jtopic";
    my $allowed = $Foswiki::cfg{Extensions}{RootJobPlugin}{Jobs} || '';
    return "Topic $jweb.$jtopic not in list of allowed job-topics!" unless $allowed =~ m/(?:^|,)\s*\Q$webtopic\E\s*(?:$|,)/; # XXX Message, Maketext, oops

    our $jobs;
    $jobs->{$webtopic} = _parseJobTopic($jweb, $jtopic) unless $jobs->{$webtopic};
    my $details = $jobs->{$webtopic}->{$job};
    return "Job '$job' not found!" unless $details; # XXX Message
    my $command = @$details[COMMAND];
    return "No command specified!" unless $command;

    my $fields = <<FIELDS;
<input type='hidden' name='rjweb' value='$jweb' />
<input type='hidden' name='rjtopic' value='$jtopic' />
<input type='hidden' name='job' value='$job' />
FIELDS
    my $columnref = @$details[OPTIONS];
    foreach my $column (@$columnref) {
        my ($name, $type, $options, $check, $messages, $format) = @$column;
        my $form;

        if (defined $type) {
            if ($type eq 'text') {
                $check ||= '';
                $form = "<input type='text' name='$name' class='RootJobPluginText'";
                $form .= "size='$options' " if $options;
                # add checks for javascript
                for (my $cindex = 0; $cindex < scalar @$check; $cindex++) {
                    my $regex = @$check[$cindex];
                    $form .= "check$cindex='$regex' ";
                    $form .= "message$cindex='@$messages[$cindex]' " if @$messages[$cindex];
                }
                $form .= '/>';
            }
            elsif ($type eq 'select') {
                unless ($options) {
                    Foswiki::Func::writeWarning("Select '$name' has no options!");
                    next;
                }
                my $optionsarray = _toOptionsArray($options);
                foreach my $optionref (@$optionsarray) {
                    my $value = $optionref->{value};
                    unless (defined $value) {
                        Foswiki::Func::writeWarning("Select-Option in $name with no value!");
                        next;
                    }
                    my $d = (defined $optionref->{display}) ? $optionref->{display}[0] : $value->[0];
                    my $selected = ($optionref->{selected}) ? ' selected=\'selected\'' : '';
                    $form .=  "<option$selected value='$value->[0]'>$d</option>";
                }
                $form ="<select name='$name'>$form</select>";
            }
            elsif ($type eq 'checkbox') {
                unless ($options) {
                    Foswiki::Func::writeWarning("Checkbox '$name' has no options!");
                    next;
                }
                $form = '';
                my $optionsarray = _toOptionsArray($options);
                foreach my $optionref (@$optionsarray) {
                    my $value = $optionref->{value};
                    unless (defined $value) {
                        Foswiki::Func::writeWarning("Checkbox-Button in $name with no value!");
                        next;
                    }
                    my $d = (defined $optionref->{display}) ? $optionref->{display}[0] : $value->[0];
                    my $selected = ($optionref->{selected}) ? ' checked=\'checked\'' : '';
                    $form .= "<input type='checkbox' name='$name' value='$value->[0]'$selected> $d</input><br />";
                }
            }
            elsif ($type eq 'radio') {
                unless ($options) {
                    Foswiki::Func::writeWarning("radio '$name' has no options!");
                    next;
                }
                $form = '';
                my $optionsarray = _toOptionsArray($options);
                foreach my $optionref (@$optionsarray) {
                    my $value = $optionref->{value};
                    unless (defined $value) {
                        Foswiki::Func::writeWarning("Radio-Button in $name with no value!");
                        next;
                    }
                    my $d = (defined $optionref->{display}) ? $optionref->{display}[0] : $value->[0];
                    my $selected = ($optionref->{selected}) ? ' checked=\'checked\'' : '';
                    $form .= "<input type='radio' name='$name' value='$value->[0]'$selected> $d</input><br />";
                }
            }
            elsif ($type eq 'label') {
                $format ||= "| \$form ||\n";
                $form = $options || '$fieldname';
            }
        } elsif ($name eq 'submit') {
            $options ||= 'Submit';
            $form = "%BUTTON{\"%MAKETEXT{\"$options\"}%\" type=\"submit\" class=\"RootJobSubmit\"}%";
            $format ||= "| \$form%CLEAR% ||\n";
        }
        if(defined $form) {
            $format ||= "| \$fieldname | \$form |\n";
            $format =~ s#\$form#$form#g;
            $format =~ s#\$job#$job#g;
            $format =~ s#\$fieldname#$name#g;
            $fields .= $format;
        }
    }

    unless($params->{fieldsonly}) {
        $fields = "\n<form name='$job' action='%SCRIPTURLPATH{\"rest\"}%/RootJobPlugin/WikiCommand' method='post' class='RootJobPluginForm'>\n$fields</form>";
    }
    
    return $fields;
}

sub _escape {
    my ($string) = @_;
    $string =~ s/{\s*vhosts([^}]*)}/_listHosts($1)/ge; # XXX inefficient, but who cares...
    $string =~ s/&#124;/|/g;
    $string =~ s/\$n/\n/g;
    $string =~ s/\$quot/"/g;
    $string =~ s/\$co/{/g;
    $string =~ s/\$cc/}/g;
    $string =~ s/\$squot/'/g;
    $string =~ s/\$dollar/\$/g;
    return $string;
}

sub _listHosts {
    my ($string) = @_;

    my ($options) = _parseAttribs($string);
    my $vhdir = $Foswiki::cfg{VirtualHostingContrib}{VirtualHostsDir};
    return '' unless $vhdir;

    my $exceptregex;
    if ($options->{except}) {
        $exceptregex = qr/$options->{except}[0]/; # _listHosts should only be used on trusted topics, so regex should be ok
    }
    my $seperator = ', ';
    if ($options->{seperator}) {
        $seperator = $options->{seperator}[0];
    }
    my $markers = $options->{marker};
    my $unmarkers = $options->{unmarker};
    my $format = '$vhost';
    $format = $options->{format}[0] if $options->{format};

    my $hosts;

    unless (opendir(DIR, $vhdir)) {
        Foswiki::Func::writeWarning("Could not open VirtualHostsDir $vhdir!");
        return '';
    }
    my @files = sort readdir(DIR);
    while (my $file = shift @files) {
        next if $file =~ m#^(?:\.|_)#;
        next if (defined $exceptregex && $file =~ $exceptregex);
        next unless (-d "$vhdir/$file");
        # check marker-files
        my $skip = 0;
        if (defined $markers) {
            foreach my $marker (@$markers) {
                $skip = 1 unless (-e "$vhdir/$file/$marker");
            }
        }
        if (defined $unmarkers) {
            foreach my $unmarker (@$unmarkers) {
                $skip = 1 if (-e "$vhdir/$file/$unmarker");
            }
        }
        next if $skip;
        if (defined $hosts) {
            $hosts .= $seperator;
        } else {
            $hosts = '';
        }
        my $formatted = $format;
        $formatted =~ s#\$vhost#$file#g;
        $hosts .= $formatted;

        #push($target, {value=>[$file]});
    }
    return $hosts if $hosts;
    return $options->{alt}[0] if $options->{alt};
    return '';
}

# Finds out if the current user is in the 'allowed'-list.
# Does it the same way WorkflowPlugin does it except it defaults to false and
# admins are not automatically allowed.
sub _isAllowed {
    my ($allow) = @_;
    return 0 unless ($allow);

    my $thisUser = Foswiki::Func::getWikiName();
    $allow =~ s#^\s*|\s*$##g;

    foreach my $user (split(/\s*,\s*/, $allow)) {
        my ( $waste, $allowed ) =
        Foswiki::Func::normalizeWebTopicName( undef, $user );
        if ( Foswiki::Func::isGroup($allowed) ) {
            return 1 if Foswiki::Func::isGroupMember( $allowed, $thisUser );
        }
        else {
            $allowed = Foswiki::Func::getWikiUserName($allowed);
            $allowed =~ s/^.*\.//;    # strip web
            return 1 if $thisUser eq $allowed;
        }
    }
    return 0;
}

# Lockdown: restrict edits of System web to AdminUser
my $handler = sub {
    return if !$Foswiki::cfg{Extensions}{RootJobPlugin}{SystemLockdown};
    my $session = $Foswiki::Plugins::SESSION;

    my ($web, $topic);
    # Upload?
    if (ref $_[0]) {
        $web = $_[1]->web;
        $topic = $_[1]->topic;
    } else {
        ($topic, $web) = @_[1..2];
    }
    return if $web ne $Foswiki::cfg{SystemWebName};
    return if $session->{user} =~ /^($Foswiki::cfg{AdminUserLogin}|$Foswiki::cfg{AdminUserWikiName}|BaseUserMapping_333)$/;

    $session->{response} = Foswiki::Response->new;
    throw Foswiki::AccessControlException( 'CHANGE', $session->{user},
        $web, $topic, $session->i18n->maketext('access denied on web') );
};
sub beforeEditHandler { &$handler; }
sub beforeSaveHandler { &$handler; }
sub beforeUploadHandler { &$handler; }

1;

__END__
Foswiki - The Free and Open Source Wiki, http://foswiki.org/

Author: Modell Aachen GmbH

Copyright (C) 2008-2014 Foswiki Contributors. Foswiki Contributors
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
