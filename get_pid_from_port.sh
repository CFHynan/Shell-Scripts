#!/bin/ksh

#
#  Filename:     get_pid_from_port.sh
#
#  Description:  Print out to the terminal any existing PID's which are currently using the supplied port number.
#                Package 'lsof' is required and Korn shell is in use to span OS flavours.
#
#  Usage:        Run from the command line: get_pid_from_port.sh <port number>
#
#  History:
#  -----------------------------------------------------------------------------------------------------------------------------
#  Date          Name                   Details
#  03/11/2010    Chris Hynan            Release.
#  28/09/2012    Chris Hynan            Support for Linux and AIX.
#  19/02/2013    Chris Hynan            Find 'lsof' utility within Red Hat and SUSE.
#  08/10/2017    Chris Hynan            Minor update - header and syntax.
#  09/10/2017    Chris Hynan            Support Ubuntu.
#  -----------------------------------------------------------------------------------------------------------------------------
#

#
# Specify required args.
#

if [[ ($# != 1)||($1 != +([0-9])) ]]
then

  printf "\nUsage: get_pid_from_port.sh <port number>\n\n"

  exit 0

fi

#
# Variables.
#

OS=`uname -s`
VER=`cat /proc/version | grep -o 'Red Hat\|SUSE\|Ubuntu' | uniq`

#
# Functions.
#

# SUN -

sun(){

  echo

  for i in `ls /proc`
  do

    pfiles $i 2> /dev/null | grep AF_INET | grep "port: ${pnum}\$"

    if [[ $? = 0 ]]
    then

      printf "\nPort ${pnum} is currently in use by PID $i\n\n"

      tmpvar=xyz

    fi

  done

  if [[ ${tmpvar} != xyz ]]
  then

    printf "Port ${pnum} is not currently in use by any process\n\n"

  fi

  exit 0

}

# HP -

hpux(){

  echo

  /usr/local/bin/lsof -i TCP:${pnum}

  TCP=$?

  /usr/local/bin/lsof -i UDP:${pnum}

  UDP=$?

  if [[ (${TCP} = 0)||(${UDP} = 0) ]]
  then

    printf "\nPort ${pnum} is currently in use by the above\n\n"

  else

    printf "Port ${pnum} is not currently in use by any process\n\n"

  fi

  exit 0

}

# Linux -

linux(){

  case "${VER}" in
    "Red Hat")
    echo
    /usr/sbin/lsof -i TCP:${pnum}
    TCP=$?
    /usr/sbin/lsof -i UDP:${pnum}
    UDP=$?
    ;;
    "SUSE"|"Ubuntu")
    echo
    /usr/bin/lsof -i TCP:${pnum}
    TCP=$?
    /usr/bin/lsof -i UDP:${pnum}
    UDP=$?
    ;;
  esac

  if [[ (${TCP} = 0)||(${UDP} = 0) ]]
  then

    printf "\nPort ${pnum} is currently in use by the above\n\n"

  else

    printf "Port ${pnum} is not currently in use by any process\n\n"

  fi

  exit 0

}

# AIX -

aix(){

  echo

  if [[ `netstat -Aan | awk '{print $1, $5}' | grep -w ${pnum} | wc -l` -eq 0 ]]
  then

    printf "Port ${pnum} is not currently in use by any process\n\n"

    exit 0

  fi

  for i in `netstat -Aan | awk '{print $1, $5}' | grep -w ${pnum} | awk '{print $1}'`
  do

    for j in `echo sockinfo ${i} tcpcb | kdb | grep proc | awk '{print $4}'`
    do

      for k in `echo 16i${j} p | dc`
      do

        print ${k} -
        echo
        ps -ef | grep ${k} | grep -v grep
        echo

      done
    done
  done

  printf "Port ${pnum} is currently in use by the above\n\n"

  exit 0

}

#
# Case statement.
#

case ${OS} in
  SunOS)
    pnum=$1
    sun
    ;;
  HP-UX)
    pnum=$1
    hpux
    ;;
  Linux)
    pnum=$1
    linux
    ;;
  AIX)
    pnum=$1
    aix
    ;;
  *)
    printf "\nError: Unsupported OS - \"${OS}\"\n\n"
    exit 1
esac

####################