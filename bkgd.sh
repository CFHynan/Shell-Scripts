#!/bin/bash

#
#  Filename:     bkgd.sh
#
#  Description:  Fork a background daemon process as a specific user in order to perform tasks.
#                Linux centric.
#
#  Usage:        Run 'bkgd.sh' from the command line.
#
#  History:
#  ----------------------------------------------------------------------------------------------------------------------------
#  Date          Name                   Details
#  18/03/2010    Chris Hynan            Release.
#  09/10/2017    Chris Hynan            Minor updates - change shell, syntax.
#  ----------------------------------------------------------------------------------------------------------------------------
#

#
# Variables.
#

user=<add specific username here>

#
# Main body.
#

if [[ ($1 = -daemon)&&(${tmpvar} = xyz) ]]
then

  # Place logic here, basic example shown, view 'nohup.out'.

  while true
  do

    echo Hi
    sleep 10

  done

fi

#
# Verify user.
#

if [[ $(id | sed 's/).*$//' | sed 's/^.*(//') != "${user}" ]]
then

  printf '\nbkgd.sh can only be run by user \"%s\"\n\n' "${user}"
  exit 1

fi

#
# Start/stop options.
#

if [[ ($# != 1)||($1 != -start)&&($1 != -stop) ]]
then

  printf '\nUsage: bkgd.sh -start|-stop\n\n'
  exit 0

fi

if [[ $1 = -start ]]
then

  if [[ $(pgrep -cf 'bkgd.sh -daemon') -eq 1 ]]
  then

    printf '\nA \"bkgd.sh -daemon\" instance is already running\n\n'

  else

    export tmpvar=xyz

    nohup bkgd.sh -daemon 2> /dev/null &

    sleep 1

    if [[ $(pgrep -cf 'bkgd.sh -daemon') -eq 1 ]]
    then

      printf '\n\"bkgd.sh -daemon\" has started\n\n'

    fi

  fi

  exit 0

fi

if [[ $1 = -stop ]]
then

  if [[ $(pgrep -cf 'bkgd.sh -daemon') -eq 1 ]]
  then

    pkill -f 'bkgd.sh -daemon'

    if [[ $(pgrep -cf 'bkgd.sh -daemon') -eq 0 ]]
    then

      printf '\n\"bkgd.sh -daemon\" has been shutdown\n\n'

    fi

  else

    printf '\nA \"bkgd.sh -daemon\" instance is not currently running\n\n'

  fi

  exit 0

fi

####################