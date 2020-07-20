# Copyright 2019 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2

EAPI=7
inherit rindeal

## github.eclass:
GITHUB_NS="Kozea"
GITHUB_REF="v${PV}"

## python-*.eclass:
PYTHON_COMPAT=( python3_{5,6,7} )

## functions: github:src_unpack
## variables: GITHUB_SRC_URI, GITHUB_HOMEPAGE
inherit github

## EXPORT_FUNCTIONS: src_prepare src_configure src_compile src_test src_install
## functions: distutils-r1_python_prepare_all
inherit distutils-r1

DESCRIPTION="Low-level CSS parser for Python"
HOMEPAGE_A=(
	"https://tinycss2.readthedocs.io/"
	"${GITHUB_HOMEPAGE}"
)
LICENSE="BSD"

SLOT="0"

SRC_URI_A=(
	"${GITHUB_SRC_URI}"
)

KEYWORDS="~amd64 ~arm ~arm64"
IUSE_A=( )

CDEPEND_A=(
)
DEPEND_A=( "${CDEPEND_A[@]}"
	"dev-python/setuptools[${PYTHON_USEDEP}]"
)
RDEPEND_A=( "${CDEPEND_A[@]}"
	"dev-python/webencodings[${PYTHON_USEDEP}]"
)

inherit arrays

src_unpack() {
	github:src_unpack
}

python_prepare_all() {
	# do not install tests
	rrm -r tinycss2/{css-parsing-tests,test_tinycss2.py}

	distutils-r1_python_prepare_all
}
