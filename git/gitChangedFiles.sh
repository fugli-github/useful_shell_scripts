#!/bin/bash

# color setting
bold=${FORCE_COLOR_BOLD:-""}
underline=${FORCE_COLOR_UNDERLINE:-""}
standout=${FORCE_COLOR_STANDOUT:-""}
normal=${FORCE_COLOR_NORMAL:-""}
black=${FORCE_COLOR_BLACK:-""}
red=${FORCE_COLOR_RED:-""}
green=${FORCE_COLOR_GREEN:-""}
yellow=${FORCE_COLOR_YELLOW:-""}
blue=${FORCE_COLOR_BLUE:-""}
magenta=${FORCE_COLOR_MAGENTA:-""}
cyan=${FORCE_COLOR_CYAN:-""}
white=${FORCE_COLOR_WHITE:-""}
# check if stdout is a terminal...
if test -t 1 && [[ -z ${normal} ]]; then
    # see if it supports colors...
    ncolors=$(tput colors)
    if test -n "${ncolors}" && test ${ncolors} -ge 8; then
        bold="$(tput bold)"
        underline="$(tput smul)"
        standout="$(tput smso)"
        normal="$(tput sgr0)"
        black="$(tput setaf 0)"
        red="$(tput setaf 1)"
        green="$(tput setaf 2)"
        yellow="$(tput setaf 3)"
        blue="$(tput setaf 4)"
        magenta="$(tput setaf 5)"
        cyan="$(tput setaf 6)"
        white="$(tput setaf 7)"
    fi
fi


#########################################

DIR=$( cd $( dirname ${BASH_SOURCE[0]} ) ; pwd )
echo "workspace is : $DIR"
#read -p "OK ? Press any key to continue "

# changedFiles=$(git diff --name-only $DIR) 
changedFiles=$(git status -s $DIR| awk '$1 ~/M/ {print $2}')
echo "changed files:--------->"
echo "${bold}${red}$changedFiles"
echo "${normal}============================================="

deletedFiles=$(git status -s $DIR| awk '$1 ~/D/ {print $2}')
echo "deleted files:--------->"
echo "${bold}${magenta}$deletedFiles"
echo "${normal}============================================="

untrackedFiles=$(git status -s $DIR| awk '$1 !~/[MD]/ {print $2}')
#echo "untrackedFiles:--------->"
#echo "${bold}${yellow}$untrackedFiles"
#echo "${normal}============================================="
#echo "============================================="
ignoredFiles=()
ignoredFiles[0]="*.patch "
ignoredFiles[1]="$(basename $0)"
ignoredFiles[2]="gitChangedFiles.sh"
# echo "ignoredFiles =  ${ignoredFiles[@]}"

fileIsIgnored() {
    result=0
    for fileIgnored in ${ignoredFiles[@]}; do
        if [[ "$1" == "$fileIgnored" ]]; then
            result=1
            break
        fi
    done

    return $result
}


newAddfile=()
iterator=0
for file in $untrackedFiles; do
    fileIsIgnored $file
    if [[ $? != 1 ]]; then
        newAddfile[$iterator]=$file
        ((iterator++))
    fi
done

echo "new added files:--------->"
echo "${bold}${yellow}${newAddfile[@]}"
echo "${normal}============================================="

newpath=new_$(date +%s)
oldpath=old_$(date +%s)
mkdir $newpath
mkdir $oldpath
chmod -R 777 $newpath
chmod -R 777 $oldpath

for file in $changedFiles
do
    # tmp=$(echo $file | awk -F / '{print $NF}')
    tmp="$(basename $file)"
    # #改动文件的相对路径的目录树
    filedir=${file%$tmp} 
    if [ ! -d "$newpath/$filedir" ]; then
        echo "${bold}${red}$newpath/$filedir"
        mkdir -p $newpath/$filedir
        mkdir -p $oldpath/$filedir
    fi  
    # #将改动的文件拷贝到new中的目录树中
    cp -f $file $newpath/$filedir
    # #将改动的文件revert
    git checkout $file 
    # #将revert的文件拷贝到old中的目录树中
    cp -f $file $oldpath/$filedir
    # #从newpath文件夹中把改动的文件拷贝回原来的地方，即恢复改动
    cp -f $newpath/$filedir/$tmp $filedir
done

for file in ${newAddfile[@]}; do
    # tmp=$(echo $file | awk -F / '{print $NF}')
    tmp="$(basename $file)"
    # #改动文件的相对路径的目录树
    filedir=${file%$tmp}

    if [ ! -d "$newpath/$filedir" ]; then
        echo "${bold}${yellow}$newpath/$filedir"
        mkdir -p $newpath/$filedir
    fi 
    # #将改动的文件拷贝到new中的目录树中
    cp -f $file $newpath/$filedir
done

for file in $deletedFiles; do
    # tmp=$(echo $file | awk -F / '{print $NF}')
    tmp="$(basename $file)"
    # #改动文件的相对路径的目录树
    filedir=${file%$tmp}

    if [ ! -d "$oldpath/$filedir" ]; then
        echo "${bold}${yellow}$oldpath/$filedir"
        mkdir -p $oldpath/$filedir
    fi 
    git checkout $file 
    # #将改动的文件拷贝到new中的目录树中
    cp -f $file $oldpath/$filedir
    rm $file
done

echo "Done"