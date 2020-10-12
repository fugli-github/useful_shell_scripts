#!/bin/bash
#set -exuo pipefail

fileType=${1:-""}

display_help() {
    echo "
////////////////////////////////////////////////////////
    Usage: $(basename $0) [fileType]
    fileType : -c change 
               -n new
               -d delete
               -a all
////////////////////////////////////////////////////////
    "
}


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

Dir=$(cd $(dirname ${BASH_SOURCE[0]});)
echo "workspace is : $Dir"

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
ignoredFiles[1]="$(basename ${BASH_SOURCE[0]})"
ignoredFiles[2]="gitChangedFiles.sh"
#echo "ignoredFiles = ${ignoredFiles[@]}"

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

# scp files to server
user=$(whoami)
#server=${user}@ouling46.emea.nsn-net.net
server=${user}@10.157.99.37
workspace=/var/fpwork/${user}/docker_workspace/l1low


ScpAllFils() {
    for file in $changedFiles; do
    scp $file ${server}:${workspace}/${file}
    done

    for file in ${newAddfile[@]}; do
        scp $file ${server}:${workspace}/${file}    
    done

    echo "login server and delete files"
    echo "===================================="
    for file in ${deletedFiles}; do 
        ssh -t ${server} "cd ${workspace}; rm ${file} " 
    done
}

if [[ "${fileType}" == "" ]] ; then
    display_help
    exit 0
fi

echo "${bold}${green}fileType is $fileType ${normal}"

case $fileType in
    "-c" )
        for file in $changedFiles; do
        scp $file ${server}:${workspace}/${file}
        done
        ;;
    "-n" )
        for file in ${newAddfile[@]}; do
            scp $file ${server}:${workspace}/${file}    
        done
        ;;
    "-d" )
        echo "login server and delete files"
        echo "===================================="
        for file in ${deletedFiles}; do 
            ssh -t ${server} "cd ${workspace}; rm ${file} " 
        done
        ;;
    "-a" )
        ScpAllFils
        ;;
    *)
        for file in $*; do
            scp $file ${server}:${workspace}/${file}
        done
        ;;
esac


