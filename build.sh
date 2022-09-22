#!/bin/bash
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
 export USE_GAPPS=true
 export NAD_BUILD_TYPE=OFFICIAL
 lunch nad_maple_dsds-user
#make sepolicy -j24
#make bootimage -j24
#make systemimage &
#make installclean
#mka nad -j30 & #dont remove that '&'
#sleep 106m #first running
#sleep 90m #second running
#sleep 105m #third running
#sleep 102m #fourth running
#kill %1
 
mka nad -j30
ccache -s
