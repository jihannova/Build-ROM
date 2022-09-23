#!/bin/bash
    
sync () {
    cd ~/rom
    time rclone copy znxtproject:ccache/$ROM_PROJECT/.repo.tar.zst ~/rom -P
    time tar -xaf .repo.tar.zst
    time rm -rf .repo.tar.zst
    repo sync -c --no-clone-bundle --no-tags --optimized-fetch --prune --force-sync -j8
    #rclone copy znxtproject:NusantaraProject/test/device_framework_manifest.xml device/sony/yoshino-common -P
    #rclone copy znxtproject:NusantaraProject/test/device_framework_manifest_dsds.xml device/sony/yoshino-common -P
    rclone copy znxtproject:NusantaraProject/test/ActivityTaskManagerService.java frameworks/base/services/core/java/com/android/server/wm -P
    cd ker*/so*/ms* && git fetch device 13-wip && git checkout FETCH_HEAD
    cd ~/rom && rm -rf hardware/xiaomi && cd packages/apps/NusantaraSystemUI && rclone copy znxtproject:NusantaraProject/test/NusantaraThemeOverlayController.kt src/com/nusantara/systemui/theme -P && git add . && git commit -m 'fix build error' && cd ~/rom
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
     export BUILD_HOSTNAME=znxt
     export BUILD_USERNAME=znxt
     export TZ=Asia/Jakarta
     #export SELINUX_IGNORE_NEVERALLOWS=true
     #export ALLOW_MISSING_DEPENDENCIES=true
     export USE_GAPPS=true
     export NAD_BUILD_TYPE=OFFICIAL
     export USE_PIXEL_CHARGING=true
     lunch nad_maple_dsds-user
    #make sepolicy -j8
    #make bootimage -j8
    #make systemimage -j8
    #make vendorimage -j8
    #make installclean
    mka nad -j8
}

compile () {
    sync
    echo "done."
    #get_repo
    build
}

push_kernel () {
  cd ~/rom/kernel/sony/ms*
  git #push github HEAD:refs/heads/cherish-12
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
#push_kernel
#push_device
#push_yoshino
#push_vendor

# Lets see machine specifications and environments
df -h
free -h
nproc
cat /etc/os*
