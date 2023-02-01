#!/bin/bash

cd $WORKDIR
mkdir -p ~/rom

git config --global user.name "ariffjenong"
git config --global user.email "arifbuditantodablekk@gmail.com"
echo "$GIT" > ~/.git-credentials
git config --global credential.helper store --file=~/.git-credentials
git config --global color.ui false
