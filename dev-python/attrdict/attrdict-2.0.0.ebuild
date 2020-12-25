# Copyright 2019 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2

EAPI=7
inherit rindeal

## git-hosting,eclass:
GITHUB_NS="bcj"
GITHUB_REF="v${PV}"

## python-*.eclass:
PYTHON_COMPAT=( python2_7 python3_{5,6,7} )

inherit github

## TODO
inherit distutils-r1

DESCRIPTION="Dictionary that allows attribute-style access"
HOMEPAGE_A=(
	"${GITHUB_HOMEPAGE}"
)
LICENSE="MIT"

SLOT="0"
SRC_URI_A=(
	"${GITHUB_SRC_URI}"
)

KEYWORDS="~amd64 ~arm ~arm64"
IUSE_A=()

CDEPEND_A=()
DEPEND_A=( "${CDEPEND_A[@]}"
	"dev-python/setuptools[${PYTHON_USEDEP}]"
)
RDEPEND_A=( "${CDEPEND_A[@]}"
	"dev-python/six[${PYTHON_USEDEP}]"
)

inherit arrays

src_unpack()
{
	github:src_unpack
}
