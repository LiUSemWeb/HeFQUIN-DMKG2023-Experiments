#!/bin/bash

if [ "$DATASET_NAME" ]
then
  if [ -f "/kobe/dataset/$DATASET_NAME/data_downloaded" ]
  then
    cp /kobe/dataset/$DATASET_NAME/dump/dump.hdt /tmp
    cp /kobe/dataset/$DATASET_NAME/config.json /tmp
  else
    echo "data not already loaded"
  fi
else
  echo "dataset name not specified"
fi

if [ "$USE_ISTIO" == "YES" ]
then
  until curl --head localhost:15021
  do echo "Waiting for Sidecar"
    sleep 3
  done
  echo "Sidecar available"
fi

# node "bin/ldf-server" /tmp/config.json
java -jar /ldf-server.jar /tmp/config.json