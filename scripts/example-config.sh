export CORE="/var/www/wiki/core"	# The directory of your core installation

export WEBCMD="/etc/init.d/apache2"	# Command to start your webserver (lighttpd or apache)
export WEBOPTS=restart	# Options to your webservers startup command

export CMDDIR="$CORE/working/work_areas/RootJobPlugin/cmd"
export WRPEMAIL="root@localhost"
export ROOTJOBLOG="$CORE/working/logs"
export WRPTMPDIR="$CORE/working/work_areas/RootJobPlugin"

export USEAPACHEVHC="0"	# Set to '1' if you use apache and VHC
export USEVHC="1"	# Set to '1' if you use VHC

export USESOLR="1"	# Set to '1' if you use Solr
export SOLR=/var/www/solr/multicore	# Your Solr home for multicore installation
export SOLRCMD="/etc/init.d/tomcat6"	# Command to start solr (ie. tomcat or jetty)
export SOLROPTS=restart	# Options to solrs startup command
export INDEXCMD="su www-data -c 'cd $CORE/tools; FOSWIKI_ROOT=$CORE ./solrjob --host %VIRTUALHOST% --mode %MODE%'"

export USEIWATCH="1"	# Set to '1' if you use IWatch
export IWATCHCMD="/etc/init.d/iwatch"	# Command to start iwatch
export IWATCHOPTS=restart	# Options to iwatches startup command
export IWATCHCFG=/etc/iwatch/iwatch.xml	# iWatch configuration file
export IWATCHXML="/etc/iwatch/iwatch.xml"
export IWATCHDTD="/etc/iwatch/iwatch.dtd"

# Do not remove these, however you can add your own if need be
export TOUCHEDCFG=
export TOUCHEDSOLRCFG=
export TOUCHEDWEBCFG=
export TOUCHEDIWATCHCFG=
