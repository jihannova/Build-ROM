#!/usr/bin/env bash

cd $WORKDIR
mkdir -p ~/.config/rclone
echo "$rclone_config" > ~/.config/rclone/rclone.conf
name_rom=$(grep "build job" $CIRRUS_WORKING_DIR/build.sh -m 1 | cut -d / -f 4)
branch_name=$(grep "build job" $CIRRUS_WORKING_DIR/build.sh | awk -F "-b " '{print $2}' | awk '{print $1}')
device=$(grep product $CIRRUS_WORKING_DIR/build.sh -m 1 | cut -d ' ' -f 3 | cut -d _ -f 2 | cut -d - -f 1)
sleep 120
rclone copy --drive-chunk-size 256M --stats 1s znxt:ccache/${name_rom}-${branch_name}/$device/ccache.tar.zst $WORKDIR -P
time tar -xaf ccache.tar.zst
rm -rf ccache.tar.zst
