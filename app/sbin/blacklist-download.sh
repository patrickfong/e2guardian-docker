#!/bin/sh
#
# blacklist-download.sh downloads the latest
# blacklist from Shalla's blacklist site
# Comes without any warranty
#
#--------------------------------------------------
# little script (for crond)
# to fetch and modify new list from shallalist.de
#--------------------------------------------------
#
# Script needs wget
#

shallaListUri="http://www.shallalist.de/Downloads/shallalist.tar.gz"
configPath="/config"
workPath="/tmp/blacklist"

##########################################

if [ ! -d $workPath ]; then
  mkdir -p $workPath
fi

# check that everything is clean before we start.
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

echo "Remove old list and move new list to $configPath/lists/shallasblacklists"
rm -rf $configPath/lists/shallasblacklists
mv $workPath/BL $configPath/lists/shallasblacklists || { echo "Unable to move new list to $configPath/shalla-blacklist" && exit 1 ; }

echo "Clean up work directory"
rm -rf $workPath/BL

exit 0
