#!/usr/bin/env bash

docker push voraciousdev/firebase-tools:${1:-latest}
docker push voraciousdev/firebase-cli:${1:-latest}
