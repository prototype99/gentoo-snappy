# Copyright 2017-2019 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2

EAPI=7
inherit rindeal

## git-hosting.eclass:
GH_RN="github:troydhanson"
GH_REF="v${PV}"

## EXPORT_FUNCTIONS: src_unpack
## variables: GH_HOMEPAGE
inherit git-hosting

DESCRIPTION="C macros for hash tables and more "
HOMEPAGE="https://troydhanson.github.io/${PN}/ ${GH_HOMEPAGE}"
LICENSE="BSD-1"

SLOT="0"

KEYWORDS="amd64 arm arm64"
IUSE_A=( test )

CDEPEND_A=()
DEPEND_A=( "${CDEPEND_A[@]}" )
RDEPEND_A=( "${CDEPEND_A[@]}" )

REQUIRED_USE_A=(  )
RESTRICT+=""

inherit arrays

src_install() {
	doheader src/*.h

	dodoc doc/{ChangeLog,userguide,ut*}.txt
}
