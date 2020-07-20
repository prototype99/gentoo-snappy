# Copyright 2016-2019 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2

EAPI="7"
inherit rindeal

GITHUB_NS="rmartin16"
GITHUB_REF="v${PV}"

PYTHON_COMPAT=( python2_7 python3_{5,6,7} )

inherit github

inherit distutils-r1

DESCRIPTION="Python client implementation for qBittorrent's Web API "
HOMEPAGE_A=(
	"${GITHUB_HOMEPAGE}"
)
LICENSE="GPL-3.0-only"

SLOT="0"
SRC_URI_A=(
	"${GITHUB_SRC_URI}"
)

KEYWORDS="~amd64 ~arm ~arm64"
IUSE_A=( )

CDEPEND_A=()
DEPEND_A=( "${CDEPEND_A[@]}" )
RDEPEND_A=( "${CDEPEND_A[@]}"
	"<dev-python/attrdict-3[${PYTHON_USEDEP}]"
	"<dev-python/requests-3[${PYTHON_USEDEP}]"
	"<dev-python/urllib3-2[${PYTHON_USEDEP}]"
)

inherit arrays

src_unpack()
{
	github:src_unpack
}
