#!/usr/bin/env bash

set -e
name_rom=$(grep "build job" $CIRRUS_WORKING_DIR/build.sh -m 1 | cut -d / -f 4)
branch_name=$(grep "build job" $CIRRUS_WORKING_DIR/build.sh | awk -F "-b " '{print $2}' | awk '{print $1}')
device=$(grep product $CIRRUS_WORKING_DIR/build.sh -m 1 | cut -d ' ' -f 3 | cut -d _ -f 2 | cut -d - -f 1)
type=$(grep type $CIRRUS_WORKING_DIR/build.sh -m 1 | cut -d ' ' -f 3 | cut -d _ -f 2 | cut -d - -f 1)
build_script=$(tail $CIRRUS_WORKING_DIR/build.sh -n +$(expr $(grep '# build rom' $CIRRUS_WORKING_DIR/build.sh -n | cut -f1 -d:) - 1)| head -n -1 | grep -v '# end')
if [[ $device != lavender ]]
   then
    curl -s https://api.telegram.org/$TG_TOKEN/sendMessage -d chat_id=$TG_CHAT_ID -d text="New Job detected:
ROM: $name_rom
device: Sony Xperia XZ Premium (${device})
Build variant: Vanilla and GApps"
else
    curl -s https://api.telegram.org/$TG_TOKEN/sendMessage -d chat_id=$TG_CHAT_ID -d text="New Job detected:
ROM: $name_rom
device: $device
Build variant: Vanilla and GApps"
fi
mkdir -p $WORKDIR/rom/$name_rom
cd $WORKDIR/rom/$name_rom
time rclone copy znxt:ccache/${name_rom}-${branch_name}/$device/.repo.tar.zst $WORKDIR/rom/$name_rom -P
time tar -xaf .repo.tar.zst
rm -rf .repo.tar.zst
sync() {
    curl -s https://api.telegram.org/$TG_TOKEN/sendMessage -d chat_id=$TG_CHAT_ID -d text="Start Sync source"
    repo sync -c --no-clone-bundle --no-tags --optimized-fetch --prune --force-sync -j8
    rm -rf hardware/nad/compat
    cd fr*/native && git apply ~/egl.diff && cd ../..
    cd boo*/reco* && curl https://github.com/CarbonROM/android_bootable_recovery/commit/48a06a2e00b9bda444f79b6b72d0c99bd89832e5.diff | git apply
    cd ../..
    curl -s https://api.telegram.org/$TG_TOKEN/sendMessage -d chat_id=$TG_CHAT_ID -d text="Sync Completed."
}
export PATH="/usr/lib/ccache:$PATH"
export CCACHE_DIR=$WORKDIR/ccache
export CCACHE_EXEC=$(which ccache)
export USE_CCACHE=1
export CCACHE_COMPRESS=true
which ccache
ccache -M 20
ccache -z
bash $CIRRUS_WORKING_DIR/script/config
export USE_PIXEL_CHARGING=true
export BUILD_HOSTNAME=NAD
export BUILD_USERNAME=znxt
export TZ=Asia/Jakarta
JOB_START=$(date +"%s")
sync
bash $CIRRUS_WORKING_DIR/script/config
bash -c "$build_script" || true
bash $CIRRUS_WORKING_DIR/script/check_build.sh
bash $CIRRUS_WORKING_DIR/script/ziping.sh
export USE_GAPPS=true
bash -c "$build_script" || true
bash $CIRRUS_WORKING_DIR/script/check_build.sh
bash $CIRRUS_WORKING_DIR/script/ziping.sh
JOB_END=$(date +"%s")
JOB_TOTAL=$(($JOB_END - $JOB_START))
curl -s https://api.telegram.org/$TG_TOKEN/sendMessage -d chat_id=$TG_CHAT_ID -d text="build job Done.
Total time elapsed: $(($JOB_TOTAL / 60)) minute(s) and $(($JOB_TOTAL % 60)) seconds"