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
     lunch cherish_maple_dsds-user
     mka bacon -j8
}

compile () {
    sync
    echo "done."
    build
}

# Sorting final zip
compiled_zip() {
    DEVICE=$(ls ~/rom/out/target/product)
	ZIP=$(find ~/rom/out/target/product/${DEVICE}/ -maxdepth 1 -name "*${DEVICE}*.zip" | perl -e 'print sort { length($b) <=> length($a) } <>' | head -n 1)
	ZIPNAME=$(basename ${ZIP})
}

build_maple () {
     cd ~/rom
     lunch cherish_maple-user
     mka bacon -j8
     compiled_zip
     upload_maple
}

# Retry the ccache fill for 99-100% hit rate
retry_cacche () {
	export CCACHE_DIR=~/ccache
	export CCACHE_EXEC=$(which ccache)
	ccache -s
	hit_rate=$(ccache -s | awk 'NR==2 { print $5 }' | tr -d '(' | cut -d'.' -f1)
	if [ $hit_rate -lt 99 ]; then
	    git clone ${TOKEN}/jihannova/Build-ROM -b ccache-cherish ${DEVICE} && cd ${DEVICE}
		git commit --allow-empty -m "Retry Build $(date -u +"%D %T%p %Z")"
	    git push origin HEAD:ccache-cherish
	else
	    echo "Ccache is fully configured"
	    git clone ${TOKEN}/jihannova/Build-ROM -b ccache-cherish ${DEVICE}
		time rclone copy znxtproject:CherishOS/ci/cchace1/repo.sh ${DEVICE} -P && cd ${DEVICE}
	    git add . && git commit -m "get ccache Done at $(date -u +"%D %T%p %Z") [skip ci]"
	    git push origin HEAD:ccache-cherish
	fi
}

# get ccache done restore to ccache 1 for next update
get_cacche_complete () {
	echo "Ccache is fully configured"
	git clone ${TOKEN}/jihannova/Build-ROM -b ccache-cherish ${DEVICE}
	time rclone copy znxtproject:CherishOS/ci/cchace1/repo.sh ${DEVICE} -P && cd ${DEVICE}
	git add . && git commit -m "get ccache Done at $(date -u +"%D %T%p %Z") [skip ci]"
	git push origin HEAD:ccache-cherish
}

upload() {
	cd ~
	rm .git-credentials .gitconfig
	git config --global user.name "jihannova"
	git config --global user.email "jihanazzahranova@gmail.com"
	echo "$TOKEN" > ~/.git-credentials
	git config --global credential.helper store --file=~/.git-credentials
	if [ -f ~/rom/out/target/product/${DEVICE}/${ZIPNAME} ]; then
		echo "Successfully Build"
		time rclone copy ~/rom/out/target/product/${DEVICE}/${ZIPNAME} znxtproject:CherishOS/${DEVICE} -P
		echo "Build maple now"
		build_maple
	else
		echo "Build failed"
		retry_cacche
	fi
}

upload_maple() {
	ROM_FILE=$(find ~/rom/out/target/product/maple/ -maxdepth 1 -name "*maple*.zip" | perl -e 'print sort { length($b) <=> length($a) } <>' | head -n 1)
	ROM_NAME=$(basename ${ROM_FILE})
	if [ -f ~/rom/out/target/product/maple/${ROM_NAME} ]; then
		echo "Successfully Build"
		time rclone copy ~/rom/out/target/product/maple/${ROM_NAME} znxtproject:CherishOS/maple -P
		get_cacche_complete
	else
		echo "Build failed"
	fi
}

cd ~/rom
ls -lh
compile #&
#sleep 100m
#kill %1
compiled_zip
upload

# Lets see machine specifications and environments
df -h
free -h
nproc
cat /etc/os*
