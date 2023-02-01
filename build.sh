# build job ///NusantaraProject/ -b 13

# product maple

# build rom
curl -s https://api.telegram.org/$TG_TOKEN/sendMessage -d chat_id=$TG_CHAT_ID -d text="Start Sync source"
repo sync -c --no-clone-bundle --no-tags --optimized-fetch --prune --force-sync -j8
curl -s https://api.telegram.org/$TG_TOKEN/sendMessage -d chat_id=$TG_CHAT_ID -d text="Sync Completed."
source $CIRRUS_WORKING_DIR/script/config
timeStart

. build/envsetup.sh
lunch nad_maple_dsds-user
mkfifo reading
tee "${BUILDLOG}" < reading &
build_message "Building Started"
progress &
mka nad -j8  > reading

retVal=$?
timeEnd
statusBuild

# build for maple
timeStart

lunch nad_maple-user
mkfifo reading
tee "${BUILDLOG}" < reading &
build_message "Building for maple now"
progress &
mka nad -j8  > reading

retVal=$?
timeEnd
statusBuild
# end