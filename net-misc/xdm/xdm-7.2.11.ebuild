# Copyright 1999-2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit java-pkg-2 java-pkg-simple

HOMEPAGE="https://subhra74.github.io/xdm/"
SRC_URI="https://github.com/subhra74/xdm/archive/7.2.11.tar.gz -> ${P}.tar.gz"
KEYWORDS="amd64"

DESCRIPTION="Powerfull download accelerator and video downloader"

LICENSE="GPL-2"
SLOT="0"
IUSE=""

DEPEND=">=dev-java/commons-net-3.6
dev-java/jna
dev-java/json-simple
>=dev-java/xz-java-1.8
>=virtual/jdk-1.9"
RDEPEND=">=virtual/jre-1.9 ${DEPEND}"