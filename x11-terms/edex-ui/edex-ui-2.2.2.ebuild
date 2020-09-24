# Copyright 1999-2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit npm

HOMEPAGE="https://github.com/GitSquared/${PN}/"
SRC_URI="${HOMEPAGE}archive/v2.2.2.tar.gz -> ${P}.tar.gz"
KEYWORDS="amd64"

DESCRIPTION="A cross-platform, customizable science fiction terminal emulator with advanced monitoring & touchscreen support."

LICENSE="GPL-3"
SLOT="0"
IUSE=""

RDEPEND=""

DEPEND=""

src_compile() {
	npm run build-linux
}