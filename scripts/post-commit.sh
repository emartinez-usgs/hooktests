#!/bin/bash

##
# This script is meant to be run as a post-commit hook on simple projects where
# auto-deployment to a subsequent server is desirable.
#
# Specifically post-commit, it pushes the master branch to the origin remote
# then logs in to a configured set of deployHosts over SSH and pulls the
# master branch down from the origin remote.
#
# NB: If the current branch is not the master branch, nothing is done. This
#     restriction may be removed in the future, but for simplicity, this
#     script currently only works on the master bracn with the origin remote.
#
# Requirements:
#   (1) Passwordless origin remote for pushes on local system
#   (2) Passwordless SSH to each server configured in deployHosts
#   (3) Passwordless origin remote for pulls on each server configured
#       in deployHosts
##


## Configuration

#
# config file provides:
#  - deployPath
#  - deployHosts
#  - deployUser
#
source ".git/hooks/config.sh";


## Usage
if [[ -z "$deployPath" || -z "$deployHosts" || -z "$deployUser" ]]; then
  echo "Incomplete configuration file. Check config.sh.";
  exit -1;
fi

remote="origin";
currentBranch=`git branch | egrep '\*' | awk '{print $2}'`;

# Only auto-deploy master branch...
if [ "$currentBranch" != "master" ]; then
  exit 0;
fi


## Script

git push $remote master;

command="cd $deployPath";
command="$command && git checkout master";
command="$command && git pull $remote master";

for server in $deployHosts; do
  ssh -l $deployUser $server "($command)";
done


## Done

exit 0;
