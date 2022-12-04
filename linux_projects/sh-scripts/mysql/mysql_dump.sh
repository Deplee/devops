#!/bin/bash
#===============================================================================
#
#          FILE: mysql_dump.sh
#
#         USAGE: ./mysql_dump.sh
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
#       CREATED: 24.11.2022 20:34
#      REVISION:  ---
#===============================================================================

#set -o nounset                              # Treat unset variables as an er


  #get credentials
  read -p "Enter DB Username: " user
  read -s -p "Enter DB Password: " password
  echo ""
  read -p "Enter DB Name: " db
  read -p "Enter dump location: " location
  read -p "Excluding tables?: " question
  #set default variables
  defaultName="mysqldump.sql"
  dt=$(date +%Y-%m-%d:%H:%M)
  #case start
  case $question in
    [yY])
      read -p "Enter excluding table name: " $extable
      mysqldump -u $user -p$password $db --ignore-table="$db"."$extable" > $location/$defaultName | gzip -c > $location/"$dt"_"$defaultName".gz
      rm -r "$location/$defaultName" ;;
    [nN])
      mysqldump -u $user -p$password $db > $location/$defaultName | gzip -c > $location/"$dt"_"$defaultName".gz
      rm -r "$location/$defaultName" ;;
  esac
