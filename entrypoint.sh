#!/bin/sh

if [ -z $FIREBASE_PROJECT_ID ]
then
  firebase $@
else
  firebase --project $FIREBASE_PROJECT_ID $@
fi
