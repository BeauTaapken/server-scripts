#!/usr/bin/env bash

CURDIR=$(dirname "$0")
source ${CURDIR}/.env

./sync-lastest-tdarr-backup.sh

pushd ~/Server
git add -u
git commit -m "automatic push"
git push
popd

pushd ~/Server-scripts
git add .
git commit -m "automatic push"
git push
popd

config='/usr/bin/git --git-dir=/home/beau/.cfg/ --work-tree=/home/beau'

$config add -u
$config commit -m "automatic push"
$config push -u origin main
