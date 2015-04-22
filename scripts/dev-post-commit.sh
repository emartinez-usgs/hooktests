#!/bin/bash

#
# config file provides:
#  - deployPath
#  - deployHosts
#  - deployUser
#
source ".git/hooks/config.sh";

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

git push $remote master;

command="cd $deployPath";
command="$command && git checkout master";
command="$command && git pull $remote master";

for server in $deployHosts; do
  ssh -l $deployUser $server "($command)";
done


exit 0;
