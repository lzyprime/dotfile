#!/bin/bash
set -e

packages_list=(
uos-service-support
uos-remote-assistance
org.deepin.browser
org.deepin.downloader
org.deepin.scanner
deepin-album
deepin-offline-update
com.uos.changxie
uos-remote-assistance
udcp
udcp-installer
dde-cooperation
dde-cooperation-transfer
deepin-data-transfer
deepin-feedback
com.deepin.lianliankan
com.deepin.gomoku
deepin-log-viewer
libreoffice 
libreoffice-common
simple-scan
deepin-home
deepin-camera
deepin-mail
deepin-music
deepin-forum
deepin-voice-note
deepin-editor
deepin-clone
remmina
uos-recovery
dde-introduction
deepin-manual
deepin-printer
dde-printer
deepin-tooltips
)

PACKAGES_LIST="$(echo "${packages_list[@]}" | tr ' ' ',')"

echo "---------pkg list---------"
echo "$PACKAGES_LIST"
echo "--------------------------"

workspace="$(mktemp -d -p .)"
mkdir -p "$workspace/DEBIAN" "$workspace/usr/local/bin"

cp "$0" "$workspace/usr/local/bin/dde-provide.make.sh-new"

cat > "$workspace/DEBIAN/control" << EEE
Package: dde-provide
Version: $(date "+%Y").$(tmp=$(date "+%m"); echo "${tmp##0}").$(tmp=$(date "+%d"); echo "${tmp##0}")-deepin1
Architecture: all
Maintainer: LinuxDeepin Project <linuxdeepin@linuxdeepin.com>
Installed-Size: 0
Provides: $PACKAGES_LIST
Replaces: $PACKAGES_LIST
Conflicts: $PACKAGES_LIST
Section: metapackages
Priority: standard
Homepage: http://www.linuxdeepin.com
Description: dde provides vir.
EEE

cat > "$workspace/DEBIAN/postinst" << EEE
#!/bin/sh
set -e

mv /usr/local/bin/dde-provide.make.sh-new /usr/local/bin/dde-provide.make.sh
chmod +x /usr/local/bin/dde-provide.make.sh
EEE
chmod +x "$workspace/DEBIAN/postinst"

fakeroot dpkg-deb -b "$workspace"
dpkg-name "$workspace".deb

rm -rf "$workspace"
