#!/bin/bash

# customises docker ps output externally
# takes options and builds the go template string then executes docker ps with it
# field labels taken from https://docs.docker.com/engine/reference/commandline/ps/ on 2018-01-20
# author Andy Heath axelafa.com, devethic.com dev@axelafa.com
# use as you wish. No guarantees

# change these to be whatever columns you want - see key in Usage
defaultoptions="-iIcspn"

# delete the -s if you only want running containers
dockercmd="ps -a"


Usage() {
# -------
cat <<eocat1>&2
Usage `basename $0`: <Options>
      where meaning of the options to include fields in the output is as follows

          -h this help text

          -i .ID         Container ID
          -I .Image      Image ID
          -c .Command    Quoted command
          -C .CreatedAt  Time when the container was created.
          -L .Label      Value of a specific label for this container. For example '{{.Label "com.docker.swarm.cpu"}}'
                         ... note that -L requires an argument so if used should be given as the last of any grouping of
                             arguments such as -cCL and followed by its argument.  Thus
                                   dps -iIL mysite -pn
                             is finei and uses mysite as the argument to the Label but
                                   dps -iLI mysite -pn
                             is not because the I following L will be taken as the argument to Label
          -l .Labels     All labels assigned to the container.
          -m .Mounts     Names of the volumes mounted in this container.
          -n .Names      Container names.
          -N .Networks   Names of the networks attached to this container.
          -p .Ports      Exposed ports.
          -r .RunningFor Elapsed time since the container was started.
          -S .Size       Container disk size.
          -s .Status     Container status.

          no options sets $defaultoptions

eocat1
}


# get the options and build the go string parts
# ---------------------------------------------
gostr=""
while getopts ":hiIcCL:lmnNprSs" opt; do
  field=""
  case $opt in
    h) Usage ; exit 1 ;;
    i) field=ID ;;
    I) field=Image ;;
    c) field=Command ;;
    C) field=CreatedAt ;;
    L) field=Label\ \"$OPTARG\" ;;
    l) field=Labels ;;
    m) field=Mounts ;;
    n) field=Names ;;
    N) field=Networks ;;
    p) field=Ports ;;
    r) field=RunningFor ;;
    S) field=Size ;;
    s) field=Status ;;
    \?) echo "Invalid option: -$OPTARG"; Usage; exit 1 ;;
    :) echo "Option -$OPTARG requires an argument."; Usage ; exit 1 ;;
  esac
  if [ ! "$gostr" ]
  then gostr={{.$field}}
  else gostr=${gostr}\\t{{.$field}}
  fi
done

# if no options go round again with default options
[ ! "$gostr" ] && exec $0 $defaultoptions

echo docker $dockercmd --format "table $gostr"
docker $dockercmd --format "table $gostr"
