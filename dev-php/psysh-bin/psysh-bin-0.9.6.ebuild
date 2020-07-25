# Copyright 2016, 2018 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2

EAPI=6
inherit rindeal

DESCRIPTION="REPL for PHP"
HOMEPAGE="https://psysh.org/ ${GH_HOMEPAGE}"
LICENSE="MIT"

PN_NB="${PN%%-bin}"
SLOT="0"
SRC_URI="https://github.com/bobthecow/${PN_NB}/releases/download/v${PV}/${PN_NB}-v${PV}.tar.gz"

KEYWORDS="~amd64 ~arm ~arm64"

RDEPEND="
	dev-lang/php
"

S="${WORKDIR}"

src_configure() { : ; }
src_compile() { : ; }

src_install() {
	dobin "${PN_NB}"
}
