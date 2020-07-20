# Copyright 1999-2019 Gentoo Authors
# Copyright 2019 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2

EAPI=7
inherit rindeal

## git-hosting.eclass:
GH_RN="github"
GH_REF="v${PV}"

## python-r1.eclass:
PYTHON_COMPAT=( pypy{,3} python2_7 python3_{5,6,7} )

## EXPORT_FUNCTIONS: src_unpack
## variables: HOMEPAGE, SRC_URI
inherit git-hosting

## EXPORT_FUNCTIONS: src_prepare src_configure src_compile src_test src_install
inherit distutils-r1

DESCRIPTION="WebSocket client for python with hybi13 support"
LICENSE="LGPL-2.1"

SLOT="0"

KEYWORDS="~amd64 ~arm ~arm64"
IUSE_A=( examples test )

CDEPEND_A=( )
DEPEND_A=( "${CDEPEND_A[@]}"
	"dev-python/setuptools[${PYTHON_USEDEP}]"
)
RDEPEND_A=( "${CDEPEND_A[@]}"
	"dev-python/six[${PYTHON_USEDEP}]"
	"$(python_gen_cond_dep 'dev-python/backports-ssl-match-hostname[${PYTHON_USEDEP}]' pypy python2_7 )"
)

inherit arrays

python_test() {
	esetup.py test
}

python_install_all() {
	if use examples
	then
		docompress -x "/usr/share/doc/${PF}/examples"
		dodoc -r examples
	fi

	distutils-r1_python_install_all
}
