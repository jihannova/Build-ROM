# build job ///NusantaraProject/ -b 13

# product maple

# type Realese

# build rom
source $CIRRUS_WORKING_DIR/script/config
timeStart

. build/envsetup.sh
if [ $USE_GAPPS ]; then
    lunch nad_maple_dsds-userdebug
    mkfifo reading
    tee "${BUILDLOG}" < reading &
    build_gapps_message "Building GApps Started"
    progress_gapps &
    mka nad -j8  > reading
else
    lunch nad_maple_dsds-userdebug
    mkfifo reading
    tee "${BUILDLOG}" < reading &
    build_message "Building Started"
    progress &
    mka nad -j8  > reading
fi

retVal=$?
timeEnd
if [ $USE_GAPPS ]; then
    statusBuildGapps
else
    statusBuild
fi
# end
