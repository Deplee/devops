#!/bin/bash
#===============================================================================
#
#          FILE: get_newest.sh
#
#         USAGE: ./get_newest.sh
#
#   DESCRIPTION:
#
#       OPTIONS: ---
#  REQUIREMENTS: ---
#          BUGS: ---
#         NOTES: ---
#        AUTHOR: David K. (@1zuna) (github.com/Deplee), dkapitsev@gmail.com
#  ORGANIZATION: GNU Software
#       LICENSE: GNU General Public License
#     COPYRIGHT: Copyright (c) 2022, David K. (@1zuna)
#       CREATED: 24.11.2022 23:05
#      REVISION:  ---
#===============================================================================

#set -o nounset                              # Treat unset variables as an er

read -p "Enter location: " location
echo ""
ls -lt $location/ | sed 1d | awk '{print $9" EDITED IN: "$8}'|\
  while read fname;
  do
    echo "FILE: ${fname}"
  done
echo "******************************************************************************************"
echo "NEWEST FILE: $(ls -lt $location/ | sed 1d | awk '{print $9}' | head -1) AND EDITED IN: \
  $(ls -lt $location/ | sed 1d | awk '{print $8}' | head -1)"
echo "******************************************************************************************"
