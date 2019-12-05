#!/bin/bash

DIR=$( cd $( dirname ${BASH_SOURCE[0]} ) ; pwd )
cd $DIR

# changedFiles=$(git status -s $DIR|awk '$1 ~/^[M]/ {print $2}' | egrep '(\.[ch](pp)?)$')
changedFiles=$(git status -s . |awk '$1 ~/^[M]/ {print $2}')
echo "$changedFiles"

#在当前目录下创建new目录，用于保存修改文件目录树
newpath=new_$(date +%s)
oldpath=old_$(date +%s)
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

echo "Done"