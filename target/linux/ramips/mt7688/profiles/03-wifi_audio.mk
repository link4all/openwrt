#
# Copyright (C) 2015 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

define Profile/wifi_audio
	NAME:=wifi_audio
	PACKAGES:=\
		kmod-usb-core kmod-usb2 kmod-usb-ohci \
		uboot-envtools kmod-ledtrig-netdev \
  		mountd \
        	uhttpd rpcd rpcd-mod-iwinfo \
		luci luci-lib-json \
		rpcd-mod-rpcsys spi-tools \
		kmod-fs-vfat kmod-i2c-core kmod-i2c-ralink \
		kmod-nls-base kmod-nls-cp437 kmod-nls-iso8859-1 kmod-nls-utf8 \
		kmod-sdhci-mt7620 kmod-usb-storage \
		kmod-sound-core kmod-sound-mtk madplay-alsa alsa-utils \
        	maccalc shairport_mmap reg
endef

define Profile/wifi_audio/Description
	wifi_audio base packages.
endef
$(eval $(call Profile,wifi_audio))
