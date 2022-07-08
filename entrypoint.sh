#!/bin/bash

_firebase() {
  if [ -z $FIREBASE_PROJECT_ID ]
  then
    firebase $@
  else
    firebase --project $FIREBASE_PROJECT_ID $@
  fi
}

_firebase $@
