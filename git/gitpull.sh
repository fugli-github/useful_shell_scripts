#!/bin/bash

#find . -maxdepth  1 -type d  -exec echo git --git-dir={}/.git --work-tree=$PWD/{} status \;
#find . -maxdepth  1 -type d  -exec git --git-dir={}/.git --work-tree=$PWD/{} pull origin master \;

#find . -type d -name .git -exec git --git-dir={} --work-tree=$PWD/{}/.. status \;
#find . -type d -name .git -exec git --git-dir={} --work-tree=$PWD/{}/.. pull origin master \;


DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd $DIR
repos="$(find . -type d -name .git)"

for repo in $repos
do
	echo "repo = "$repo
	#get local branch name
	branch="$(git --git-dir=${repo} symbolic-ref -q --short HEAD)"
	echo "git pull origin " $branch
	git --git-dir=${repo} --work-tree=$repo/.. pull origin $branch

done




