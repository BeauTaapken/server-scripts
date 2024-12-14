#!/usr/bin/env bash

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
