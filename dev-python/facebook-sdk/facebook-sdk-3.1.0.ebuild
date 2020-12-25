# Copyright 2019 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2

EAPI=7
inherit rindeal

## git-hosting,eclass:
GITHUB_NS="mobolic"
GITHUB_REF="v${PV}"

## python-*.eclass:
PYTHON_COMPAT=( python2_7 python3_{5,6,7} )

## TODO
inherit github

## TODO
inherit distutils-r1

DESCRIPTION="Python SDK for Facebook's Graph API"
HOMEPAGE_A=(
	"${GITHUB_HOMEPAGE}"
)
LICENSE="Apache-2.0"

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
	"dev-python/requests[${PYTHON_USEDEP}]"
)

inherit arrays
