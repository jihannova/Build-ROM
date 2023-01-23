#!/bin/bash
    
sync () {
    cd ~/rom
    time rclone copy znxtproject:ccache/$ROM_PROJECT/.repo.tar.zst ~/rom -P
    time tar -xaf .repo.tar.zst
    time rm -rf .repo.tar.zst
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
     lunch nad_lavender-userdebug
     #make bootimage vendorimage
     #make systemimage -j8
     make nad -j8
}

build_gapps () {
     cd ~/rom
     make installclean
     export USE_GAPPS=true
     make nad -j8
     compiled_zip
     upload_gapps
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

# Retry the ccache fill for 99-100% hit rate
retry_cacche () {
	export CCACHE_DIR=~/ccache
	export CCACHE_EXEC=$(which ccache)
	hit_rate=$(ccache -s | awk '/hit rate/ {print $4}' | cut -d'.' -f1)
	if [ $hit_rate -lt 99 ]; then
	    echo "Retry Build"
	    git clone ${TOKEN}/jihannova/Build-ROM -b 13-${DEVICE} ${DEVICE} && cd ${DEVICE}
	    git add . && git commit -m --allow-empty "Retry Build $(date -u +"%D %T%p %Z")"
	    git push origin HEAD:13-${DEVICE}
	else
	    echo "Retry Build"
	    git clone ${TOKEN}/jihannova/Build-ROM -b 13-${DEVICE} ${DEVICE} && cd ${DEVICE}
	    git add . && git commit -m --allow-empty "Retry Build $(date -u +"%D %T%p %Z")"
	    git push origin HEAD:13-${DEVICE}
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
		echo "Uploading ${ZIPNAME}"
		time rclone copy ~/rom/out/target/product/${DEVICE}/${ZIPNAME} znxtproject:NusantaraProject/${DEVICE} -P
		echo "Build GApps now"
		build_gapps
	else
		echo "Build failed"
		retry_cacche
	fi
}

upload_gapps() {
	cd ~
	echo "Successfully Build"
	echo "Uploading ${ZIPNAME}"
	time rclone copy ~/rom/out/target/product/${DEVICE}/${ZIPNAME} znxtproject:NusantaraProject/${DEVICE} -P
}

cd ~/rom
ls -lh
compile #&
#sleep 55m
#sleep 60m
#kill %1
compiled_zip
upload

# Lets see machine specifications and environments
df -h
free -h
nproc
cat /etc/os*
