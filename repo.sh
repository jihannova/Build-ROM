#!/bin/bash
    
sync () {
    cd ~/rom
    time rclone copy znxtproject:ccache/$ROM_PROJECT/maple/.repo.tar.zst ~/rom -P
    time tar -xaf .repo.tar.zst
    time rm -rf .repo.tar.zst
    repo sync -c --no-clone-bundle --no-tags --optimized-fetch --prune --force-sync -j8
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
     lunch nad_maple_dsds-user
     mka nad -j8
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
     lunch nad_maple-user
     mka nad -j8
     compiled_zip
     upload_maple
}

# Retry the ccache fill for 99-100% hit rate
retry_cacche () {
	export CCACHE_DIR=~/ccache
	export CCACHE_EXEC=$(which ccache)
	hit_rate=$(ccache -s | awk 'NR==2 { print $5 }' | tr -d '(' | cut -d'.' -f1)
	if [ $hit_rate -lt 95 ]; then
	    git clone ${TOKEN}/jihannova/Build-ROM -b ccache-nad ${DEVICE} && cd ${DEVICE}
		git commit --allow-empty -m "Retry Cacche $(date -u +"%D %T%p %Z")"
	    git push origin HEAD:ccache-nad
	else
	    echo "Ccache is fully configured"
	fi
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
		# time rclone copy ~/rom/out/target/product/${DEVICE}/${ZIPNAME} znxtproject:$ROM_PROJECT/${DEVICE} -P
		echo "Build maple now"
	    #build_maple
		retry_cacche
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
		time rclone copy ~/rom/out/target/product/maple/${ROM_NAME} znxtproject:$ROM_PROJECT/maple -P
	else
		echo "Build failed"
	fi
}

cd ~/rom
ls -lh
compile &
sleep 110m
kill %1
compiled_zip
upload

# Lets see machine specifications and environments
df -h
free -h
nproc
cat /etc/os*
