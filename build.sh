#!/usr/bin/env bash

docker build -t voraciousdev/firebase-tools:${1:-latest} .
docker build -t voraciousdev/firebase-cli:${1:-latest} .
