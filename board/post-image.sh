#!/bin/bash

set -e

GENIMAGE_CFG="$(dirname "$0")/genimage-${BOARDNAME}.cfg"
GENIMAGE_TMP="${BUILD_DIR}/genimage.tmp"

for arg in "$@"
do
	case "${arg}" in
		--configure-picam)
		# config.txt and cmdline.txt come from board/config.txt and
		# board/cmdline.txt (BR2_PACKAGE_RPI_FIRMWARE_{CONFIG,CMDLINE}_FILE)

		# Add default camera.txt and add custom config if it exists
		cp "$BR2_EXTERNAL_PICAM_PATH/package/piwebcam/camera.txt" "${BINARIES_DIR}/camera.txt"
		if [ -f "$BR2_EXTERNAL_PICAM_PATH/camera.txt" ]; then
			cat << __EOF__ >> "${BINARIES_DIR}/camera.txt"

# User settings added during build

__EOF__
			cat "$BR2_EXTERNAL_PICAM_PATH/camera.txt" >> "${BINARIES_DIR}/camera.txt"
		fi

		# Add default enable-serial-debug file
		cat << __EOF__ > "${BINARIES_DIR}/enable-serial-debug"
# This file signifies that you want to enable the serial debug console
# via the USB port. Once you have configured the webcam to your needs
# it is recommended that you delete this file. This action ensures that
# your webcam's firmware won't be changed by the host computer's software.
#
# In the future, we will not place this file here by default, instead you'll
# have to manually create this file if you want to access the console.
__EOF__

		;;
	esac

done

# Pass an empty rootpath. genimage makes a full copy of the given rootpath to
# ${GENIMAGE_TMP}/root so passing TARGET_DIR would be a waste of time and disk
# space. We don't rely on genimage to build the rootfs image, just to insert a
# pre-built one in the disk image.

trap 'rm -rf "${ROOTPATH_TMP}"' EXIT
ROOTPATH_TMP="$(mktemp -d)"

rm -rf "${GENIMAGE_TMP}"

genimage \
	--rootpath "${ROOTPATH_TMP}"   \
	--tmppath "${GENIMAGE_TMP}"    \
	--inputpath "${BINARIES_DIR}"  \
	--outputpath "${BINARIES_DIR}" \
	--config "${GENIMAGE_CFG}"

exit $?
