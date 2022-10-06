#!/bin/bash

# Sorting final zip
compiled_zip() {
	ZIP=$(find $(pwd)/out/target/product/maple_dsds/ -maxdepth 1 -name "*maple_dsds*.zip" | perl -e 'print sort { length($b) <=> length($a) } <>' | head -n 1)
	ZIPNAME=$(basename ${ZIP})
 DEVICE=$(ls $(pwd)/out/target/product)
}

# Retry the ccache fill for 99-100% hit rate
retry_ccache () {
    export CCACHE_DIR=~/ccache
    export CCACHE_EXEC=$(which ccache)
	hit_rate=$(ccache -s | awk '/hit rate/ {print $4}' | cut -d'.' -f1)
	if [ $hit_rate -lt 99 ]; then
		git clone ${TOKEN}/jihannova/Build-ROM -b 13 clone && cd clone
		git commit --allow-empty -m "Retry: Ccache loop $(date -u +"%D %T%p %Z")"
		git push -q
	else
		echo "Ccache is fully configured"
		git clone ${TOKEN}/jihannova/Build-ROM -b 13 clone && cd clone
		git commit --allow-empty -m "Retry Build $(date -u +"%D %T%p %Z")"
		git push -q
	fi
}

# Trigger retry only if compilation is not finished
retry_event() {
	if [ -f $(pwd)/out/target/product/map*/${ZIPNAME} ]; then
		echo "Successfully Build"
  time rclone copy $(pwd)/out/target/product/maple_dsds/${ZIPNAME} znxtproject:NusantaraProject/${ROM_PROJECT}/${DEVICE} -P
	else
		retry_ccache
	fi
}

cd ~/rom
#sleep 59m
sleep 117m
rm ~/.git-credentials ~/.gitconfig
git config --global user.name "jihannova"
git config --global user.email "jihanazzahranova@gmail.com"
echo "$TOKEN" > ~/.git-credentials
git config --global credential.helper store --file=~/.git-credentials
#sleep 7191
compiled_zip
retry_event
