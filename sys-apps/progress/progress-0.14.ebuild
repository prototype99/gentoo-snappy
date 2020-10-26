# Copyright 1999-2016 Gentoo Foundation
# Copyright 2016-2018 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2

EAPI=6
inherit rindeal

## git-hosting.eclass:
GH_RN="github:Xfennec"
GH_REF="v${PV}"

## EXPORT_FUNCTIONS: src_unpack
## variables: HOMEPAGE, SRC_URI
inherit git-hosting

DESCRIPTION="Linux tool to show progress for cp, mv, dd, and virtually any command"
LICENSE="GPL-3"

SLOT="0"

KEYWORDS="amd64 arm arm64"

CDEPEND_A=(
	"sys-libs/ncurses:0="
)
DEPEND_A=( "${CDEPEND_A[@]}"
	"virtual/pkgconfig"
)
RDEPEND_A=( "${CDEPEND_A[@]}" )

inherit arrays

pkg_setup() {
	export PREFIX="${EPREFIX}/usr"
}
