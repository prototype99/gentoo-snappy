# Copyright 1999-2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

PYTHON_COMPAT=( py{py3,thon3_6} )

DISTUTILS_USE_SETUPTOOLS=rdepend

inherit distutils-r1

DESCRIPTION="A VPN command-line tool from protonvpn - python rewrite"
GITPAGE="https://github.com/0jdxt/protonvpn-rs"
HOMEPAGE="https://protonvpn.com ${GITPAGE}"
NUM="d4adbb14e0eca05168ee660b28a0534def2a0483"
SRC_URI="${GITPAGE}/archive/${NUM}.zip -> ${P}.zip"

LICENSE="GPL-3"
KEYWORDS="~amd64"
SLOT="0"

RDEPEND="net-vpn/openvpn"
DEPEND="${RDEPEND}"

S="${WORKDIR}/protonvpn-rs-${NUM}"

DOCS=( CHANGELOG.md README.md USAGE.md )