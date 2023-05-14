#!/bin/bash
    
sync () {
    cd ~/rom
    time rclone copy znxt:ccache/$ROM_PROJECT/lavender/.repo.tar.zst ~/rom -P
    time tar -xaf .repo.tar.zst
    time rm -rf .repo.tar.zst
    repo sync -c --no-clone-bundle --no-tags --optimized-fetch --prune --force-sync -j8
    cd ker*/x*/la* && git fetch ariffjenong 13-b --depth=1 && git checkout FETCH_HEAD
}

build () {
     cd ~/rom
     . build/envsetup.sh
     export CCACHE_DIR=~/ccache
     export CCACHE_EXEC=$(which ccache)
     export USE_CCACHE=1
     ccache -M 50G
     ccache -z
     export BUILD_HOSTNAME=NAD
     export BUILD_USERNAME=znxt
     export TZ=Asia/Jakarta
     lunch nad_lavender-userdebug
     make bootimage -j8
}

compile () {
    sync
    echo "done."
    #get_repo
    build
}

upload() {
    cd ~
	time rclone copy ~/rom/out/target/product/lavender/boot.img znxt:NusantaraProject/lavender/tes -P
}

cd ~/rom
ls -lh
compile
upload

# Lets see machine specifications and environments
df -h
free -h
nproc
cat /etc/os*
