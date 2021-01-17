# Copyright 2019 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2

EAPI=7
inherit rindeal

GITHUB_NS="Matroska-Org"
GITHUB_REF="release-${PV}"

inherit github

## EXPORT_FUNCTIONS: src_prepare src_configure src_compile src_test src_install
inherit cmake-utils

DESCRIPTION="C++ libary to parse Matroska files"
HOMEPAGE_A=(
	"${GITHUB_HOMEPAGE}"
)
LICENSE_A=(
	"LGPL-2.1-or-later"
)

libmatroska_soname_maj=6
SLOT="0/${libmatroska_soname_maj}"
SRC_URI_A=(
	"${GITHUB_SRC_URI}"
)

KEYWORDS="amd64 arm arm64"
IUSE_A=(  )

CDEPEND_A=(
	">=dev-libs/libebml-1.3.9:="
)
DEPEND_A=( "${CDEPEND_A[@]}" )
RDEPEND_A=( "${CDEPEND_A[@]}" )

REQUIRED_USE_A=(  )
RESTRICT+=""

inherit arrays

src_unpack()
{
	github:src_unpack
}

src_install()
{
	cmake-utils_src_install

	if ! [[ -e "${ED}/usr/$(get_libdir)/libmatroska.so.${libmatroska_soname_maj}" ]]
	then
		eqawarn "FIXME: libmatroska SONAME changed, please update ebuild subslot"
	fi
}
