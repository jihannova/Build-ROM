#!/bin/bash
    
sync () {
    cd ~/rom
    repo init --depth=1 --no-repo-verify -u ${Nusantara} -b 13 -g default,-mips,-darwin,-notdefault
    rclone copy znxtproject:NusantaraProject/manifest/13-lavender/nusantara.xml .repo/manifests/snippets -P
    rclone copy znxtproject:NusantaraProject/local_manifests/13-lavender/nad_lavender.xml .repo/local_manifests -P
    repo sync -c --no-clone-bundle --no-tags --optimized-fetch --prune --force-sync -j8
    repo sync -c --no-clone-bundle --no-tags --optimized-fetch --prune --force-sync -j8
}

com () {
    #tar --use-compress-program="pigz -k -$2 " -cf $1.tar.gz $1
    tar "-I zstd -1 -T2" -cf $1.tar.zst $1
}

get_repo () {
  cd ~/rom
  time com .repo 1
  time rclone copy .repo.tar.* znxtproject:ccache/$ROM_PROJECT -P
  time rm *tar.*
  ls -lh
}

compile () {
    sync
    echo "done."
    get_repo
    #build
}

cd ~/rom
ls -lh
compile

# Lets see machine specifications and environments
df -h
free -h
nproc
cat /etc/os*
