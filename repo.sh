#!/bin/bash
    
sync () {
    cd ~/rom
    time rclone copy znxtproject:ccache/$ROM_PROJECT/.repo.tar.zst ~/rom -P
    time tar -xaf .repo.tar.zst
    time rm -rf .repo.tar.zst
    repo sync -c --no-clone-bundle --no-tags --optimized-fetch --prune --force-sync -j8 frameworks/base
    cd fr*/b* && git fetch nad 13-arif && git checkout FETCH_HEAD
    rclone copy znxtproject:NusantaraProject/test/FooterActionsController.kt packages/SystemUI/src/com/android/systemui/qs -P
    git add . && git commit --amend --no-edit
    git push nad HEAD:13-arif -f
    cd ~/rom
    rm -rf hardware/xiaomi/IF*
}

com () {
    #tar --use-compress-program="pigz -k -$2 " -cf $1.tar.gz $1
    tar "-I zstd -1 -T2" -cf $1.tar.zst $1
}

get_repo () {
  cd ~/rom
  time com .repo 1
  time rclone copy .repo.tar.* znxtproject:ccache/$ROM_PROJECT -P
  time rm .repo.tar.*
  ls -lh
}

build () {
     cd ~/rom
     . build/envsetup.sh
     export CCACHE_DIR=~/ccache
     export CCACHE_EXEC=$(which ccache)
     export USE_CCACHE=1
     ccache -M 50G
     ccache -z
     export BUILD_HOSTNAME=NusantaraProject
     export BUILD_USERNAME=znxt
     export TZ=Asia/Jakarta
     #export SELINUX_IGNORE_NEVERALLOWS=true
     #export ALLOW_MISSING_DEPENDENCIES=true
     export USE_GAPPS=true
     export NAD_BUILD_TYPE=OFFICIAL
     export USE_PIXEL_CHARGING=true
     lunch nad_maple_dsds-user
    make SystemUI -j8
    #make Settings -j8
    #make systemimage -j8
    #make vendorimage -j8
    #make installclean
    #mka nad -j8
}

compile () {
    sync
    echo "done."
    #get_repo
    #build
}

push_ui () {
  cd ~/rom/out/target/product/map*/system/sys*ext/priv*/SystemUI && ls
  rclone copy SystemUI.apk znxtproject:NusantaraProject/test -P
}

push_device () {
  cd ~/rom/device/sony/maple_dsds
  git #push github HEAD:cherish-12 -f
}

push_yoshino () {
  cd ~/rom/device/sony/yos*
  git #push github HEAD:cherish-12 -f
}

push_vendor () {
  cd ~/rom/vendor/sony/maple_dsds
  git #push github HEAD:cherish-12 -f
}

cd ~/rom
ls -lh
compile #&
#sleep 55m
#sleep 113m
#kill %1
#push_ui
#push_device
#push_yoshino
#push_vendor

# Lets see machine specifications and environments
df -h
free -h
nproc
cat /etc/os*
