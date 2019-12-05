#!/bin/bash
curpath=$(pwd)

#获取版本库中修改文件
filename=$(svn st -q |awk '$1 ~ /^[M\!]/ {print $2}' | egrep '(\.[ch](pp)?)$')

#在当前目录下创建new目录，用于保存修改文件目录树
if [ ! -d "new" ]; then
	echo "create new old dir"
	mkdir new
	mkdir old
fi

newpath="new"
oldpath="old"
chmod -R 777 $newpath
chmod -R 777 $oldpath

#文件夹，用于存放改动的文件
changedfilesfolder=changedfilesfoldertmp
if [ ! -d $changedfilesfolder ];  then
	mkdir $changedfilesfolder
fi
chmod -R 777 $changedfilesfolder


MAKEFILES=Makefile
for file in $filename
do
	tmp=$(echo $file | awk -F / '{print $NF}')
	filedir1=${file/#$curpath/}
	#改动文件的相对路径的目录树
	filedir=${filedir1/%$tmp/}
	
	filedirOriginal=${file/%$tmp/} 

	if [ ! -d "$newpath/$filedir" ]; then
		echo "$newpath/$filedir"
		mkdir -p $newpath/$filedir
		mkdir -p $oldpath/$filedir
	fi	
	#将改动的文件拷贝到new中的目录树中
	cp -f $file $newpath/$filedir
	#将改动的文件拷贝到临时文件夹中
	cp -f $file $changedfilesfolder
	#将改动的文件revert
    svn revert $file 
	#将revert的文件拷贝到old中的目录树中
	cp -f $file $oldpath/$filedir
	#在从临时文件夹中把改动的文件拷贝回原来的地方，即恢复改动
	cp -f $changedfilesfolder/$tmp $filedirOriginal
	
done

