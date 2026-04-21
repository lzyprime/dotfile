#!/bin/bash
set -euf

[ "$(whoami)" != "root" ] && { sudo bash "$0"; exit $?; }

NO_DISPLAY=(
'/usr/share/applications/deepin-manual.desktop'
'/usr/share/applications/deepin-compressor.desktop'
'/usr/share/applications/dde-introduction.desktop'
'/usr/share/applications/dde-computer.desktop'
'/usr/share/applications/deepin-screen-recorder.desktop'
'/usr/share/applications/deepin-image-viewer.desktop'
'/usr/share/applications/dde-calendar.desktop'
'/usr/share/applications/deepin-log-viewer.desktop'
'/usr/share/applications/deepin-deb-installer.desktop'
'/usr/share/applications/deepin-devicemanager.desktop'
'/usr/share/applications/deepin-reader.desktop'
'/usr/share/applications/deepin-system-monitor.desktop'
'/usr/share/applications/deepin-album.desktop'
'/usr/share/applications/deepin-music.desktop'
'/usr/share/applications/deepin-movie.desktop'
'/usr/share/applications/deepin-font-manager.desktop'
'/usr/share/applications/dde-printer.desktop'
'/usr/share/applications/deepin-screen-recorder.desktop'
'/usr/share/applications/deepin-diskmanager.desktop'
'/usr/share/applications/wps-office-wps.desktop'
'/usr/share/applications/wps-office-wpp.desktop'
'/usr/share/applications/wps-office-pdf.desktop'
'/usr/share/applications/wps-office-et.desktop'
'/usr/share/applications/wps-office-prometheus.desktop'
'/usr/share/applications/dde-trash.desktop'
'/usr/share/applications/org.deepin.browser.desktop'
'/usr/share/applications/downloader.desktop'
'/usr/share/applications/deepin-camera.desktop'
'/usr/share/applications/sogouIme-configtool-deepin.desktop'
'/usr/share/applications/display-im6.q16.desktop'
'/usr/share/applications/sogouIme-configtool-uos.desktop'
'/usr/share/applications/uos-service-support.desktop'
'/usr/share/applications/uos-remote-assistance.desktop'
'/usr/share/applications/com.sogou.ime.next.uos.configurer.desktop'
)

for i in "${NO_DISPLAY[@]}"; do
	[ ! -f "$i" ] && continue
	if grep -q "NoDisplay=" "$i"; then
		sed -i "/NoDisplay=/cNoDisplay=true" "$i"
	else
		sed -i '1aNoDisplay=true' "$i"
	fi
done

# [ -f "/usr/share/applications/google-chrome.desktop" ] && sed -i "/Icon=/cIcon=/usr/share/icons/prime-custom/google-chrome.png" /usr/share/applications/google-chrome.desktop

cat > "/usr/share/applications/all-application.desktop" << EEE
[Desktop Entry]
Version=1.0
Name=所有应用
Exec=dde-file-manager -n /usr/share/applications
Terminal=false
Type=Application
Icon=uos-windesk
Categories=Utility;
Comment=打开 /usr/share/applications
EEE

exit 0
