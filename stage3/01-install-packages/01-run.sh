#!/bin/bash -e

## Install BiteDJ from pre-built dist-linux
BITEDJ_DIST=""
if [ -d "${BASE_DIR}/dist-linux" ]; then
    BITEDJ_DIST="${BASE_DIR}/dist-linux"
elif [ -d "${BASE_DIR}/../dist-linux" ]; then
    BITEDJ_DIST="${BASE_DIR}/../dist-linux"
elif [ -d "/dist-linux" ]; then
    BITEDJ_DIST="/dist-linux"
fi

if [ -z "${BITEDJ_DIST}" ] || [ ! -f "${BITEDJ_DIST}/bin/mixxx" -a ! -f "${BITEDJ_DIST}/bin/bitedj" ]; then
    echo "ERROR: BiteDJ build artifacts not found! Expected ${BITEDJ_DIST:-/dist-linux}/bin/mixxx" >&2
    echo "Please build BiteDJ first using ./scripts/build/docker-build.sh" >&2
    exit 1
fi

echo "==> Installing pre-built BiteDJ from ${BITEDJ_DIST} into rootfs..."
mkdir -p "${ROOTFS_DIR}/usr"
cp -a "${BITEDJ_DIST}/"* "${ROOTFS_DIR}/usr/"

# Ensure binary symlinks and execute permissions
if [ -f "${ROOTFS_DIR}/usr/bin/mixxx" ] && [ ! -f "${ROOTFS_DIR}/usr/bin/bitedj" ]; then
    ln -sf mixxx "${ROOTFS_DIR}/usr/bin/bitedj"
elif [ -f "${ROOTFS_DIR}/usr/bin/bitedj" ] && [ ! -f "${ROOTFS_DIR}/usr/bin/mixxx" ]; then
    ln -sf bitedj "${ROOTFS_DIR}/usr/bin/mixxx"
fi
chmod 755 "${ROOTFS_DIR}/usr/bin/mixxx" "${ROOTFS_DIR}/usr/bin/bitedj" 2>/dev/null || true

# Set version metadata expected by export-image stage
mkdir -p "${ROOTFS_DIR}/opt"
echo "bitedj-1.0" > "${ROOTFS_DIR}/opt/mixxx.version"
echo "v1.0" > "${ROOTFS_DIR}/opt/mixxx.tag"
echo "bitedj-1.0" > "${ROOTFS_DIR}/opt/bitedj.version"
echo "==> BiteDJ installed successfully."
