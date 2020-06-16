#!/bin/bash

fileIsfound() {
    result=0
    for changeFile in $changedFiles; do
        if [[ "$1" == "$changeFile" ]]; then
            result=1
            break
        fi
    done

    return $result
}

DIR=$( cd $( dirname ${BASH_SOURCE[0]} ) ; pwd )

if [ $1 ]; then
    DIR=$1
fi

echo "workspace is : $DIR"
#read -p "OK ? Press any key to continue "

changedFiles=$(git diff --name-only $DIR) 
echo "changed files:--------->"
echo "$changedFiles"
echo "============================================="
echo "============================================="

allFiles=$(git status -s $DIR| awk '{print $2}')
echo "all files:--------->"
echo "$allFiles"
echo "============================================="
echo "============================================="

iterator=0
for file in $allFiles; do
    fileIsfound $file
    if [[ $? == 1 ]]; then
        echo "$file is found in changedFiles"
    else
        echo "$file is NOT found in changedFiles"
        newAddfile[$iterator]=$file
        ((iterator++))
    fi
done


newpath=new_$(date +%Y%m%d-%H%M%S)
oldpath=old_$(date +%Y%m%d-%H%M%S)
mkdir $newpath
mkdir $oldpath
chmod -R 777 $newpath
chmod -R 777 $oldpath

for file in $changedFiles
do
    tmp=$(echo $file | awk -F / '{print $NF}')
    # #改动文件的相对路径的目录树
    filedir=${file%$tmp}

    if [ ! -d "$newpath/$filedir" ]; then
        echo "$newpath/$filedir"
        mkdir -p $newpath/$filedir
        mkdir -p $oldpath/$filedir
    fi  
    # #将改动的文件拷贝到new中的目录树中
    cp -f $file $newpath/$filedir
    # #将改动的文件revert
    git checkout $file 
    # #将revert的文件拷贝到old中的目录树中
    cp -f $file $oldpath/$filedir
    # #从临时文件夹中把改动的文件拷贝回原来的地方，即恢复改动
    cp -f $newpath/$filedir/$tmp $filedir
done

for file in ${newAddfile[@]}; do
    tmp=$(echo $file | awk -F / '{print $NF}')
    # #改动文件的相对路径的目录树
    filedir=${file%$tmp}

    if [ ! -d "$newpath/$filedir" ]; then
        echo "$newpath/$filedir"
        mkdir -p $newpath/$filedir
    fi 
    # #将改动的文件拷贝到new中的目录树中
    cp -f $file $newpath/$filedir
done

echo "Done"