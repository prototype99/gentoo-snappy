# Copyright 2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit cmake desktop

DESCRIPTION="A Qt based cross-platform screenshot tool that provides many annotation features for your screenshots"
HOMEPAGE="https://github.com/ksnip/ksnip"
SRC_URI="https://github.com/ksnip/ksnip/archive/v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

QV="-5.9.4:5"
RDEPEND="
		>=dev-qt/qtdbus${QV}
		>=dev-qt/qtnetwork${QV}
		>=dev-qt/qtprintsupport${QV}
		>=dev-qt/qtx11extras${QV}
		>=dev-qt/qtxml${QV}
		>=x11-libs/kimageannotator-0.3.1"
DEPEND="${RDEPEND}"
BDEPEND=""

src_install() {
	cmake_src_install

	doicon -s scalable desktop/ksnip.svg
	domenu desktop/ksnip.desktop
}

pkg_postinst() {
	xdg_desktop_database_update
	xdg_icon_cache_update
}

pkg_postrm() {
	xdg_desktop_database_update
	xdg_icon_cache_update
}
