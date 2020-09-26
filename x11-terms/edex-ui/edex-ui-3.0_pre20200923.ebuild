# Copyright 1999-2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

HOMEPAGE="https://github.com/GitSquared/${PN}/"
NUM="b4456a650d13a441c8c957279a0b62ad0f90d5f4"
SRC_URI="${HOMEPAGE}archive/${NUM}.zip -> ${P}.zip"
KEYWORDS="amd64"

DESCRIPTION="A cross-platform, customizable science fiction terminal emulator with advanced monitoring & touchscreen support."

LICENSE="GPL-3"
SLOT="0"
IUSE=""

DEPEND="net-libs/nodejs[npm]"

RESTRICT="network-sandbox"

S="${WORKDIR}/${PN}-${NUM}"

src_compile() {
	npm install || die
	npm run build-linux || die
}

src_install(){
	mkdir -p "${D}/opt/${PN}/"
	mv "${S}"/dist/linux-unpacked/* "${D}/opt/${PN}/"
	newbin "${FILESDIR}/${PN}.sh" "${PN}"
}