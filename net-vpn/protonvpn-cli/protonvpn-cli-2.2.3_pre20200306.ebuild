# Copyright 1999-2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

PYTHON_COMPAT=( py{py3,thon3_6} )

DISTUTILS_USE_SETUPTOOLS=rdepend

inherit distutils-r1

DESCRIPTION="A VPN command-line tool from protonvpn - python rewrite"
GITPAGE="https://github.com/ProtonVPN/linux-cli"
HOMEPAGE="https://protonvpn.com ${GITPAGE}"
NUM="f0a859ec5e3dfe8cbdcb37fc8160a8b101c76469"
SRC_URI="${GITPAGE}/archive/${NUM}.zip -> ${P}.zip"

LICENSE="GPL-3"
KEYWORDS="~amd64"
SLOT="0"

RDEPEND="dev-python/docopt[${PYTHON_USEDEP}]
	dev-python/requests[${PYTHON_USEDEP}]
	dev-python/pythondialog:0[${PYTHON_USEDEP}]
	net-vpn/openvpn"
DEPEND="${RDEPEND}"

S="${WORKDIR}/linux-cli-${NUM}"

DOCS=( CHANGELOG.md README.md USAGE.md )
