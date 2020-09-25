# Copyright 1999-2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

NODE_MODULE_DEPEND="uglify-es"

inherit node-module

HOMEPAGE="https://github.com/GitSquared/${PN}/"
SRC_URI="${HOMEPAGE}archive/v2.2.2.tar.gz -> ${P}.tar.gz"
KEYWORDS="amd64"

DESCRIPTION="A cross-platform, customizable science fiction terminal emulator with advanced monitoring & touchscreen support."

LICENSE="GPL-3"
SLOT="0"
IUSE=""

RDEPEND="${RDEPEND}"
DEPEND="${RDEPEND}
net-libs/nodejs[npm]"

S="${WORKDIR}/${P}"

src_compile() {
	npm run build-linux || die
}