# Copyright 2016-2018 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2

EAPI=6
inherit rindeal

GH_RN="github:googlemaps:${PN}-python"
PYTHON_COMPAT=( python2_7 python3_{5,6} )

## EXPORT_FUNCTIONS: src_prepare src_configure src_compile src_test src_install
inherit distutils-r1
## EXPORT_FUNCTIONS: src_unpack
inherit git-hosting

DESCRIPTION="Python client library for Google Maps API Web Services"
LICENSE="Apache-2.0"

SLOT="0"

# ~arm/~arm64 is missing dev-python/responses package
KEYWORDS="~amd64"
IUSE_A=( test )

CDEPEND_A=(
	">=dev-python/requests-2.11.1[${PYTHON_USEDEP}]"
	"<dev-python/requests-3.0[${PYTHON_USEDEP}]"
)
DEPEND_A=( "${CDEPEND_A[@]}"
	"test? ("
		"dev-python/nose[${PYTHON_USEDEP}]"
		"dev-python/responses[${PYTHON_USEDEP}]"
	")"
)
RDEPEND_A=( "${CDEPEND_A[@]}" )

inherit arrays

python_test() {
	nosetests --verbosity=3 || die
}
