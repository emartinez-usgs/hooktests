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

configFile=".git/hooks/post-commit.config";
remote="origin";
branch="master";

if [ ! -f $configFile ]; then
  echo "Configuration file does not exist.";
  exit -1;
fi

# config file provides:
#  - deployHosts
#  - deployPath
#  - deployUser
source $configFile;


## Usage

if [[ -z "$deployHosts" || -z "$deployPath" || -z "$deployUser" ]]; then
  echo "Incomplete configuration file. Check config.sh.";
  exit -2;
fi

if [ `git branch | egrep '\*' | awk '{print $2}'` != "$branch" ]; then
  echo "Current branch is $branch. Nothing done.";
  exit 0;
fi


## Script

git push $remote $branch;

command="cd $deployPath";
command="$command && git checkout $branch";
command="$command && git pull $remote $branch";

for server in $deployHosts; do
  ssh -l $deployUser $server "($command)";
done


## Done

exit 0;
