# build job ///CherishOS/ -b tiramisu

# product maple

# type Realese

# build rom
source $CIRRUS_WORKING_DIR/script/config
timeStart

rm device/cherish/sepolicy/common/public/property.te
rclone copy znxtproject:CherishOS/frameworks/ActivityTaskManagerService.java fr*/b*/services/core/java/com/android/server/wm -P
. build/envsetup.sh
lunch cherish_maple_dsds-user
mkfifo reading
tee "${BUILDLOG}" < reading &
build_gapps_message "Building Started"
progress_gapps &
mka bacon -j8 > reading

retVal=$?
timeEnd
statusBuildGapps
bash $CIRRUS_WORKING_DIR/script/ziping.sh

# build for maple
source $CIRRUS_WORKING_DIR/script/config
timeStart

lunch cherish_maple-user
mkfifo reading
tee "${BUILDLOG}" < reading &
build_gapps_message "Building for maple Now"
progress_gapps &
mka bacon -j8 > reading

retVal=$?
timeEnd
statusBuildGapps
# end
