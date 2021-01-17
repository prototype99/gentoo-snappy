# Copyright 2018-2019 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2

EAPI=7
inherit rindeal

## github.eclass:
GITHUB_NS="goldmann"

## python-*.eclass:
PYTHON_COMPAT=( python2_7 python3_{5,6,7} )

## distutils-r1.eclass:
DISTUTILS_SINGLE_IMPL=1

## self-explanatory
inherit github

## EXPORT_FUNCTIONS: src_prepare src_configure src_compile src_test src_install
inherit distutils-r1

DESCRIPTION="Docker image squashing tool"
HOMEPAGE_A=(
	"${GITHUB_HOMEPAGE}"
)
LICENSE="MIT"

SLOT="0"

SRC_URI_A=(
	"${GITHUB_SRC_URI}"
)

KEYWORDS="~amd64 ~arm ~arm64"
IUSE_A=( )

CDEPEND_A=()
DEPEND_A=( "${CDEPEND_A[@]}" )
RDEPEND_A=( "${CDEPEND_A[@]}"
	"dev-python/docker-py[${PYTHON_USEDEP}]"
)

REQUIRED_USE_A=(  )
RESTRICT+=""

inherit arrays

src_unpack()
{
	github:src_unpack
}
