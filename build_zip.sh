#!/bin/bash

com () {
    #tar --use-compress-program="pigz -k -$2 " -cf $1.tar.gz $1
    tar "-I zstd -1 -T2" -cf $1.tar.zst $1
}

get_ccache () {
  cd ~
  time com ccache 1
  time rclone copy ccache.tar.* znxtproject:ccache/$ROM_PROJECT/maple -P
  time rm ccache.tar.*
  ls -lh
}

get_ccache

# Lets see machine specifications and environments
  df -h
  free -h
  nproc
  cat /etc/os*
