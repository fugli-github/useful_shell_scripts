#!/bin/bash  
#cp trace/* gnb/uplane/build/l2_ps/build/src/ttiTrace/decoder/csvOutput
#cd gnb/uplane/build/l2_ps/build/src/ttiTrace/decoder/csvOutput
#rm -rf *.csv

files=$(ls 5GTtiTrace.bin.*.tar.gz | sort -n -t "." -k 3)

ite=1
for file in $files
do
  bin=$(tar -zxvf $file)
  sh ../TtiTraceDecoder.sh $bin $bin
  rm -rf $bin
  if [ "$ite" -eq 1 ]
  then
    cat "$bin".dl.csv | head -n 1 >> dl.csv
    cat "$bin".ul.csv | head -n 1 >> ul.csv
  fi
  cat "$bin".dl.csv | tail -n +3 >> dl.csv
  cat "$bin".ul.csv | tail -n +3 >> ul.csv
  ((ite++))
done

#rm -rf 5GTtiTrace.*



