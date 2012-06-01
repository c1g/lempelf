#!/bin/sh
###############################################################################
# author:andychu
# date:2008-9-9
# version:1.0

cd /opt/awstats/wwwroot/cgi-bin/;
./awstats.pl -update -config=admin.server.com -databasebreak=day
