#!/bin/bash
curpath=$(pwd)

#��ȡ�汾�����޸��ļ�
filename=$(svn st -q |awk '$1 ~ /^[M\!]/ {print $2}' | egrep '(\.[ch](pp)?)$')

#�ڵ�ǰĿ¼�´���newĿ¼�����ڱ����޸��ļ�Ŀ¼��
if [ ! -d "new" ]; then
	echo "create new old dir"
	mkdir new
	mkdir old
fi

newpath="new"
oldpath="old"
chmod -R 777 $newpath
chmod -R 777 $oldpath

#�ļ��У����ڴ�ŸĶ����ļ�
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
	#�Ķ��ļ������·����Ŀ¼��
	filedir=${filedir1/%$tmp/}
	
	filedirOriginal=${file/%$tmp/} 

	if [ ! -d "$newpath/$filedir" ]; then
		echo "$newpath/$filedir"
		mkdir -p $newpath/$filedir
		mkdir -p $oldpath/$filedir
	fi	
	#���Ķ����ļ�������new�е�Ŀ¼����
	cp -f $file $newpath/$filedir
	#���Ķ����ļ���������ʱ�ļ�����
	cp -f $file $changedfilesfolder
	#���Ķ����ļ�revert
    svn revert $file 
	#��revert���ļ�������old�е�Ŀ¼����
	cp -f $file $oldpath/$filedir
	#�ڴ���ʱ�ļ����аѸĶ����ļ�������ԭ���ĵط������ָ��Ķ�
	cp -f $changedfilesfolder/$tmp $filedirOriginal
	
done

