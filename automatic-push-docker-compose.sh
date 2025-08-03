#!/usr/bin/env bash

CURDIR=$(dirname "$0")
source ${CURDIR}/.env

pushd ~/Server
./sync-lastest-tdarr-backup.sh
popd

git add -u
git commit -m "automatic push"
git push

pushd ~/Server-scripts
git add .
git commit -m "automatic push"
git push
popd

config='/usr/bin/git --git-dir=/home/beau/.cfg/ --work-tree=/home/beau'

$config add -u
$config commit -m "automatic push"
$config push -u origin main
