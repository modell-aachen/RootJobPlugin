# ---+ Extensions
# ---++ RootJobPlugin
# **BOOLEAN**
# Whether to prevent edits to System for anyone but AdminUser. DOES NOT PREVENT MOVING!
$Foswiki::cfg{Extensions}{RootJobPlugin}{SystemLockdown} = 0;
# **PATH**
# Where this plugin will store its commands.
$Foswiki::cfg{Extensions}{RootJobPlugin}{cmdDir} = '';
# **STRING**
# Enter the name of the topics that describe allowed jobs.
# Comma sepparated list.
$Foswiki::cfg{Extensions}{RootJobPlugin}{Jobs} = '';
