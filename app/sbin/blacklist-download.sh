#!/bin/sh
#
# shalla_update.sh, v 0.3.1 20080403
# done by kapivie at sil.at under FreeBSD
# without any warranty
# updated by Len Tucker to create and use diff
# files to reduce load and increase speed.
# Added Checks for required elements
# Added output info for status of script
# Modified by Chris Kronberg: included loop; added some more
# checks; reduced the diff files to the necessary content.
#
#--------------------------------------------------
# little script (for crond)
# to fetch and modify new list from shallalist.de
#--------------------------------------------------
#
# *check* paths and squidGuard-owner on your system
# try i.e. "which squid" to find out the path for squid
# try "ps aux | grep squid" to find out the owner for squidGuard
#     *needs wget*
#

shallaListUri="http://www.shallalist.de/Downloads/shallalist.tar.gz"
configPath="/config"
workPath="/tmp/blacklist"

##########################################

if [ ! -d $workPath ]; then
  mkdir -p $workPath
fi

# check that everything is clean before we start.
if [ -f  $workPath/shallalist.tar.gz ]; then
   echo "Old blacklist file found in ${workPath}. Deleted!"
   rm $workPath/shallalist.tar.gz
fi

if [ -d $workPath/BL ]; then
   echo "Old blacklist directory found in ${workPath}. Deleted!"
   rm -rf $workPath/BL
fi

# copy actual shalla's blacklist
# thanks for the " || exit 1 " hint to Rich Wales
# (-b run in background does not work correctly) -o log to $wgetlog

echo "Retrieving shallalist.tar.gz"
wget $shallaListUri -O $workPath/shallalist.tar.gz || { echo "Unable to download shallalist.tar.gz." && exit 1 ; }

echo "Unzippping shallalist.tar.gz"
tar zxf $workPath/shallalist.tar.gz -C $workPath || { echo "Unable to extract $workPath/shallalist.tar.gz." && exit 1 ; }

echo "Remove old list and move new list to $configPath/shalla-blacklist"
rm -rf $configPath/shalla-blacklist
mv $workPath/BL $configPath/shalla-blacklist || { echo "Unable to move new list to $configPath/shalla-blacklist" && exit 1 ; }

echo "Clean up downloaded file and directories."
rm $workPath/shallalist.tar.gz
rm -rf $workPath/BL

exit 0
