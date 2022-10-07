#!/bin/bash
    
sync () {
    cd ~/rom
    time rclone copy znxtproject:ccache/$ROM_PROJECT/.repo.tar.zst ~/rom -P
    time tar -xaf .repo.tar.zst
    time rm -rf .repo.tar.zst
    repo sync -c --no-clone-bundle --no-tags --optimized-fetch --prune --force-sync -j8
    rm device/cherish/sepolicy/common/public/property.te
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
     lunch cherish_maple_dsds-user
    #make bootimage -j8
    #make vendorimage -j8
    #make systemimage -j8
    mka bacon -j8
}

compile () {
    sync
    echo "done."
    #get_repo
    build
}

# Sorting final zip
compiled_zip() {
    DEVICE=$(ls $(pwd)/out/target/product)
	ZIP=$(find $(pwd)/out/target/product/${DEVICE}/ -maxdepth 1 -name "*${DEVICE}*.zip" | perl -e 'print sort { length($b) <=> length($a) } <>' | head -n 1)
	ZIPNAME=$(basename ${ZIP})
}

upload() {
	if [ -f $(pwd)/out/target/product/map*/${ZIPNAME} ]; then
		echo "Successfully Build"
        time rclone copy $(pwd)/out/target/product/${DEVICE}/${ZIPNAME} znxtproject:CherishOS/${DEVICE} -P
		echo "Build for maple now"
		cd ~
		rm ~/.git-credentials ~/.gitconfig
		git config --global user.name "jihannova"
		git config --global user.email "jihanazzahranova@gmail.com"
		echo "$TOKEN" > ~/.git-credentials
		git config --global credential.helper store --file=~/.git-credentials
		git clone ${TOKEN}/jihannova/Build-ROM -b cherish-13 ${DEVICE}
		time rclone copy znxtproject:CherishOS/ci/maple/repo.sh ${DEVICE} -P
		time rclone copy znxtproject:CherishOS/ci/maple/.cirrus.yml ${DEVICE} -P
		cd ${DEVICE}
        git add . && git commit -m "build for maple now" && git push origin HEAD:cherish-13
	else
		echo "Build failed"
	fi
}

cd ~/rom
ls -lh
compile #&
#sleep 55m
#sleep 113m
#kill %1

# Lets see machine specifications and environments
df -h
free -h
nproc
cat /etc/os*
