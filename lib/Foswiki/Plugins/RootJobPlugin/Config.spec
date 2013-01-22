# ---+ Extensions
# ---++ RootJobPlugin
# **BOOLEAN**
# Whether to prevent edits to System for anyone but AdminUser. DOES NOT PREVENT MOVING!
$Foswiki::cfg{Extensions}{RootJobPlugin}{SystemLockdown} = 0;
# **STRING**
# User needs write-permissions to this topic if he wants to administrate the wiki.
$Foswiki::cfg{Extensions}{RootJobPlugin}{PermissionTopic} = 'RootJobPlugin';
# **STRING**
# The PermissionTopic is in this web.
$Foswiki::cfg{Extensions}{RootJobPlugin}{PermissionWeb} = 'System';
# **PATH**
# Where this plugin will store its commands.
$Foswiki::cfg{Extensions}{RootJobPlugin}{cmdDir} = '';
# **STRING**
# Enter the name of the topics that describe allowed jobs.
# Comma sepparated list.
$Foswiki::cfg{Extensions}{RootJobPlugin}{Jobs} = '';
