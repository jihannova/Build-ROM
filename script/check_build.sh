#!/usr/bin/env bash

msg() {
    echo -e "\e[1;32m$*\e[0m"
}

name_rom=$(grep "build job" $CIRRUS_WORKING_DIR/build.sh -m 1 | cut -d / -f 4)
a=$(grep '#### build completed successfully' $WORKDIR/rom/$name_rom/build.log -m1 || true)
if [[ $a == *'#### build completed successfully'* ]]
  then
  echo ━━━━━━━━━ஜ۩۞۩ஜ━━━━━━━━
  msg ✅ Build is completed 100% ✅
  echo ━━━━━━━━━ஜ۩۞۩ஜ━━━━━━━━
else
  echo ━━━━━━━━━ஜ۩۞۩ஜ━━━━━━━━
  msg ❌ ...Build not completed... ❌
  echo ━━━━━━━━━ஜ۩۞۩ஜ━━━━━━━━
fi
