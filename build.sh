# build job ///NusantaraProject/ -b 13

# product lavender

# build rom
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
bash $CIRRUS_WORKING_DIR/script/ziping.sh

# build for maple
source $CIRRUS_WORKING_DIR/script/config
timeStart

. build/envsetup.sh
lunch nad_lavender-userdebug
mkfifo reading
tee "${BUILDLOG}" < reading &
build_message "Building Started"
progress &
mka nad -j8  > reading

retVal=$?
timeEnd
statusBuild
# end
