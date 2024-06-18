#!/bin/bash
FNAME="/sevod-scraper/output/"$DATASET_NAME".nt"

touch $FNAME

TYPE1='sparql'
TYPE2='brtpf'
TYPE3='hdtdata'
if [[ $DATASET_ENDPOINT == *"$TYPE1"* ]]; then
  echo "ex:"$DATASET_NAME"
      a            fd:FederationMember ;
      fd:interface [ a                  fd:SPARQLEndpointInterface ;
                     fd:endpointAddress <"$DATASET_ENDPOINT"> ] ." >> $FNAME
elif [[ $DATASET_ENDPOINT == *"$TYPE2"* ]]; then
  echo "ex:"$DATASET_NAME"
      a            fd:FederationMember ;
      fd:interface [ a                         fd:brTPFInterface ;
                     fd:exampleFragmentAddress <"$DATASET_ENDPOINT""$DATASET_NAME"> ] ." >> $FNAME
elif [[ $DATASET_ENDPOINT == *"$TYPE3"* ]]; then
  echo "ex:"$DATASET_NAME"
      a            fd:FederationMember ;
      fd:interface [ a                         fd:TPFInterface ;
                     fd:exampleFragmentAddress <"$DATASET_ENDPOINT"> ] ." >> $FNAME
else
  echo $DATASET_ENDPOINT >> $FNAME
fi