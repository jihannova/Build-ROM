#!/usr/bin/env bash

msg() {
    echo -e "\e[1;32m$*\e[0m"
}

telegram_message() {
    curl -s -X POST "https://api.telegram.org/$TG_TOKEN/sendMessage" \
    -d chat_id="$TG_CHAT_ID" \
    -d parse_mode="HTML" \
    -d text="$1"
}

function enviroment() {
name_rom=$(grep "build job" $CIRRUS_WORKING_DIR/build.sh -m 1 | cut -d / -f 4)
device=$(ls $WORKDIR/rom/$name_rom/out/target/product)
file_name=$(basename $(find $WORKDIR/rom/$name_rom/out/target/product/${device}/ -maxdepth 1 -name "*${device}*.zip" | perl -e 'print sort { length($b) <=> length($a) } <>' | head -n 1))
branch_name=$(grep "build job" $CIRRUS_WORKING_DIR/build.sh | awk -F "-b " '{print $2}' | awk '{print $1}')
rel_date=$(date "+%Y%m%d")
DATE_L=$(date +%d\ %B\ %Y)
DATE_S=$(date +"%T")
}

function upload_rom() {
echo ━━━━━━━━━ஜ۩۞۩ஜ━━━━━━━━
msg Upload rom..
echo ━━━━━━━━━ஜ۩۞۩ஜ━━━━━━━━
cd $WORKDIR/rom/$name_rom
rclone copy out/target/product/$device/${file_name} znxt:$name_rom/$device -P
cd out/target/product/$device
echo -e \
"
<b>✅ Build Completed Successfully ✅</b>
━━━━━━━━━ஜ۩۞۩ஜ━━━━━━━━
<b>🚀 Rom Name :- "${name_rom}"</b>
<b>📁 File Name :- "${file_name}"</b>
<b>⏰ Timer Build</b> :- "$(grep "#### build completed successfully" $WORKDIR/rom/$name_rom/build.log -m 1 | cut -d '(' -f 2)"
<b>📱 Device</b> :- "${device}"
<b>📂 Size :- "$(ls -lh ${file_name} | cut -d ' ' -f5)"</b>
<b>🖥 Branch Build</b> :- "${branch_name}"
<b>📅 Date</b> :- "$(date +%d\ %B\ %Y)"
<b>🕔 Time Zone</b> :- "$(date +%T)"
<b>📕 MD5 :-</b> <code>"$(md5sum ${file_name} | cut -d' ' -f1)"</code>
<b>📘 SHA1 :-</b> <code>"$(sha1sum ${file_name} | cut -d' ' -f1)"</code>
<b>📥 Download link :- "GDrive/${device}"</b>
━━━━━━━━━ஜ۩۞۩ஜ━━━━━━━━
" > tg.html
TG_TEXT=$(< tg.html)
telegram_message "$TG_TEXT"
echo
echo ━━━━━━━━━ஜ۩۞۩ஜ━━━━━━━━
msg Upload rom succes..
echo ━━━━━━━━━ஜ۩۞۩ஜ━━━━━━━━
echo
echo Download Link: ${DL_LINK}
echo
echo
cd ..
  if [[ $device == maple_dsds ]]
      then
      rm -rf $device
  elif [[ $USE_GAPPS ]]
      then
      echo ━━━━━━━━━ஜ۩۞۩ஜ━━━━━━━━
      msg Upload ccache..
      echo ━━━━━━━━━ஜ۩۞۩ஜ━━━━━━━━
      upload_ccache
  else
      rm $device/$file_name
  fi
}

function upload_ccache() {
cd $WORKDIR
com ()
{
  tar "-I zstd -1 -T2" -cf $1.tar.zst $1
}
time com ccache 1
rclone copy --drive-chunk-size 256M --stats 1s ccache.tar.zst znxt:ccache/${name_rom}-${branch_name}/$device -P
rm -rf ccache.tar.zst
echo ━━━━━━━━━ஜ۩۞۩ஜ━━━━━━━━
msg Upload ccache succes..
echo ━━━━━━━━━ஜ۩۞۩ஜ━━━━━━━━
}

function upload() {
enviroment
a=$(grep '#### build completed successfully' $WORKDIR/rom/$name_rom/build.log -m1 || true)
if [[ $a == *'#### build completed successfully'* ]]
  then
  echo ━━━━━━━━━ஜ۩۞۩ஜ━━━━━━━━
  msg ✅ Build completed 100% success ✅
  echo ━━━━━━━━━ஜ۩۞۩ஜ━━━━━━━━
  echo
  echo
  upload_rom
else
  echo ━━━━━━━━━ஜ۩۞۩ஜ━━━━━━━━
  msg ❌ Build not completed, Upload ccache only ❌
  msg Upload ccache..
  echo ━━━━━━━━━ஜ۩۞۩ஜ━━━━━━━━
  upload_ccache
fi
}

upload
