#!/bin/sh

if [ "$DATASET_NAME" ]
then
  mkdir /kobe/dataset/$DATASET_NAME
  cd /kobe/dataset/$DATASET_NAME
  
  if [ ! -f "data_downloaded" ]
  then
    if [ "$DOWNLOAD_URL" ]
    then
    
      mkdir dump
      touch dump/dump.hdt
      
      mkdir tmp
      cd tmp
      
      echo "starting data downloading"
      wget $DOWNLOAD_URL
      echo "finished downloading"
      
      cd ..
      # for FILE in `ls *.hdt`
      # do
      cp tmp/*.hdt dump/dump.hdt
      # done
      
      # cd ..
      rm -rf tmp

      cp /config.json .
      sed -i 's/DATASET_NAME/'$DATASET_NAME'/g' config.json
      
      touch data_downloaded
      
    else
      echo "download url not specified"
    fi
  else
    echo "data already downloaded"
  fi
else
  echo "dataset name not specified"
fi
