# Copyright 2018-2019 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2

EAPI=7
inherit rindeal

## git-hosting.eclass:
GH_RN="github:so-fancy"
GH_REF="v${PV}"

## EXPORT_FUNCTIONS: src_unpack
inherit git-hosting

DESCRIPTION="Good-lookin' diffs. Actually... nah... The best-lookin' diffs."
LICENSE="MIT"

SLOT="0"

KEYWORDS="~amd64 ~arm ~arm64"
IUSE_A=( )

CDEPEND_A=()
DEPEND_A=( "${CDEPEND_A[@]}" )
RDEPEND_A=( "${CDEPEND_A[@]}"
	"dev-lang/perl:0"
)

REQUIRED_USE_A=(  )
RESTRICT+=""

inherit arrays

pkg_setup() {
	MY_LIB_DIR="/usr/$(get_libdir)/${PN}"
}

src_prepare() {
	eapply_user

	rsed -e "s|^use lib .*$|use lib \"${EPREFIX}${MY_LIB_DIR}\";|" -i -- "${PN}"
}

src_configure() { : ; }
src_compile() { : ; }

src_install() {
	dobin "${PN}"

	insinto "${MY_LIB_DIR}"
	doins lib/*

	einstalldocs
}
