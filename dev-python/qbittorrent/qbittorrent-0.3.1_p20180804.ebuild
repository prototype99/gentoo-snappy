# Copyright 2016-2019 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2

EAPI="7"
inherit rindeal

GITHUB_NS="v1k45"
GITHUB_PROJ="python-qBittorrent"
GITHUB_REF="04f9482"  # Aug 4, 2018

PYTHON_COMPAT=( python2_7 python3_{5,6,7} )

inherit github

inherit distutils-r1

DESCRIPTION="Python wrapper for qBittorrent Web API (for versions above v3.1.x)"
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
	"dev-python/requests[${PYTHON_USEDEP}]"
)

inherit arrays

src_unpack()
{
	github:src_unpack
}
