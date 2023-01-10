#!/bin/bash
    
sync () {
    cd ~/rom
    time rclone copy znxtproject:ccache/$ROM_PROJECT/.repo.tar.zst ~/rom -P
    time tar -xaf .repo.tar.zst
    time rm -rf .repo.tar.zst
    repo sync -c --no-clone-bundle --no-tags --optimized-fetch --prune --force-sync -j8
    rm device/cherish/sepolicy/common/public/property.te
    cd fr*/b*
    rclone copy znxtproject:CherishOS/frameworks/ActivityTaskManagerService.java services/core/java/com/android/server/wm -P
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
     lunch cherish_maple-user
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

SF () {
    cd ~/rom/out/target/product/${DEVICE}
    project=xperia-xz-premium/CherishOS/tiramisu/${DEVICE}

    # Upload
    expect -c "
    spawn sftp $SF_USERNAME@frs.sourceforge.net:/home/pfs/project/$project
    expect \"yes/no\"
    send \"yes\r\"
    expect \"Password\"
    send \"$SF_PASS\r\"
    set timeout -1
    expect \"sftp>\"
    send \"put ${ZIPNAME}\r\"
    expect \"Uploading\"
    expect \"100%\"
    expect \"sftp>\"
    send \"bye\r\"
    interact"
}

# Retry the ccache fill for 99-100% hit rate
retry_cacche () {
	export CCACHE_DIR=~/ccache
	export CCACHE_EXEC=$(which ccache)
	hit_rate=$(ccache -s | awk '/hit rate/ {print $4}' | cut -d'.' -f1)
	if [ $hit_rate -lt 99 ]; then
	    git clone ${TOKEN}/jihannova/Build-ROM -b cherish-13 ${DEVICE} && cd ${DEVICE}
	    git commit --allow-empty -m "Retry Cacche $(date -u +"%D %T%p %Z")"
	    git push -q
	else
	    echo "Ccache is fully configured"
	    git clone ${TOKEN}/jihannova/Build-ROM -b cherish-13 ${DEVICE}
		time rclone copy znxtproject:CherishOS/ci/${DEVICE}/repo.sh ${DEVICE} -P && cd ${DEVICE}
	    git add . && git commit -m "Build $(date -u +"%D %T%p %Z")"
	    git push origin HEAD:cherish-13
	fi
}

upload() {
	cd ~
	rm ~/.git-credentials ~/.gitconfig
	git config --global user.name "jihannova"
	git config --global user.email "jihanazzahranova@gmail.com"
	echo "$TOKEN" > ~/.git-credentials
	git config --global credential.helper store --file=~/.git-credentials
	if [ -f ~/rom/out/target/product/${DEVICE}/${ZIPNAME} ]; then
		echo "Successfully Build"
        SF
		echo "Done"
		git clone ${TOKEN}/jihannova/Build-ROM -b cherish-13 ${DEVICE}
		time rclone copy znxtproject:CherishOS/ci/maple_dsds/build_zip.sh ${DEVICE} -P
		time rclone copy znxtproject:CherishOS/ci/maple_dsds/repo.sh ${DEVICE} -P
		time rclone copy znxtproject:CherishOS/ci/maple_dsds/.cirrus.yml ${DEVICE} -P
		cd ${DEVICE}
        git add . && git commit -m "Done [skip ci]" && git push origin HEAD:cherish-13
	else
		echo "Build failed"
		retry_cacche
	fi
}

cd ~/rom
ls -lh
compile #&
#sleep 55m
#sleep 113m
#kill %1
compiled_zip
upload

# Lets see machine specifications and environments
df -h
free -h
nproc
cat /etc/os*
