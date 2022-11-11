#!/bin/bash
  cd ~
  ls -lh
  #time tar xf ccache.tar.gz
  #time rm ccache.tar.gz
  time tar -xaf ccache.tar.zst
  time rm -rf ccache.tar.zst

# Lets see machine specifications and environments
  df -h
  free -h
  nproc
  cat /etc/os*