# Copyright 2019 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2

EAPI=7
inherit rindeal

## github.eclass:
GITHUB_NS="ansilove"

## functions: github:src_unpack
## variables: GITHUB_HOMEPAGE, GITHUB_SRC_URI
inherit github

## EXPORT_FUNCTIONS src_prepare src_configure src_compile src_test src_install
inherit cmake-utils

DESCRIPTION="ANSi/ASCII art to PNG converter in C"
HOMEPAGE_A=(
	"https://www.ansilove.org/"
	"${GITHUB_HOMEPAGE}"
)
LICENSE="BSD-2"

SLOT="0"
SRC_URI_A=(
	"${GITHUB_SRC_URI}"
)

KEYWORDS="~amd64 ~arm ~arm64"
IUSE_A=( )

CDEPEND_A=(
	"media-libs/gd:*"
)
DEPEND_A=( "${CDEPEND_A[@]}"
)
RDEPEND_A=( "${CDEPEND_A[@]}"
)

inherit arrays

src_unpack() {
	github:src_unpack
}
