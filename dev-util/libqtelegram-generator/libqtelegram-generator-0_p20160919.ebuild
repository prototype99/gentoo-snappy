# Copyright 2016 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2

EAPI=6
inherit rindeal

GH_RN="github:Aseman-Land:libqtelegram-code-generator"
GH_REF="29462b49f094e88d2d65efeb6b98254d814294fc"

inherit git-hosting
inherit qmake-utils

DESCRIPTION="Generates API part of libqtelegram automatically"
LICENSE="GPL-2"

SLOT="0"

KEYWORDS="~amd64"

CDEPEND_A=(
	"dev-qt/qtcore:5"
)
DEPEND_A=( "${CDEPEND_A[@]}" )
RDEPEND_A=( "${CDEPEND_A[@]}" )

inherit arrays

src_configure() {
	eqmake5 "${PN}.pro"
}

src_install() {
	exeinto /usr/libexec
	doexe "${PN}"

	einstalldocs
}
