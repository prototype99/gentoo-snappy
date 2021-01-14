# Copyright 1999-2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=6
inherit eutils gnome2-utils xdg
DESCRIPTION="The legendary Git GUI client for Windows, Mac and Linux"
HOMEPAGE="https://www.gitkraken.com"
SRC_URI="https://release.axocdn.com/linux/GitKraken-v7.4.1.tar.gz"
RESTRICT="mirror"
KEYWORDS="~amd64"
SLOT="0"
LICENSE="gitkraken-EULA"
IUSE="gnome-keyring"
RDEPEND="gnome-keyring? ( gnome-base/libgnome-keyring )
	dev-libs/libgcrypt
	dev-libs/nss
	virtual/udev
	x11-libs/gtk+:3
	x11-libs/libnotify
	x11-libs/libxkbfile
	x11-libs/libXtst"

QA_PREBUILT="opt/gitkraken-bin/resources/app.asar.unpacked/node_modules/nodegit/build/Release/nodegit.node
	opt/gitkraken-bin/gitkraken"KEYWORDS="-* ~amd64"
QA_PRESTRIPPED="/opt/gitkraken-bin/libffmpeg.so
	/opt/gitkraken-bin/libnode.so"

S=${WORKDIR}/gitkraken

src_install() {
	local destdir="/opt/${PN}"
	insinto $destdir
	doins -r /
	exeinto $destdir
	doexe gitkraken
	doicon -s 512 "$FILESDIR"/gitkraken.png
	dosym $destdir/gitkraken /usr/bin/gitkraken
	make_desktop_entry gitkraken Gitkraken "gitkraken" Network
}

pkg_preinst() {
	xdg_pkg_preinst
	gnome2_icon_savelist
}

pkg_postinst() {
	xdg_pkg_postinst
	gnome2_icon_cache_update
}

pkg_postrm() {
	xdg_pkg_postrm
	gnome2_icon_cache_update
}
