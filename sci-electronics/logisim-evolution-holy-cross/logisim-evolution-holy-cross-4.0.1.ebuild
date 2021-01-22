# Copyright 1999-2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit eutils java-pkg-2 java-ant-2

NUM="c7d642b530b14065f8b86dde50ffb74280088723"
DESCRIPTION="Digital logic designer and simulator."
HOMEPAGE="https://github.com/kevinawalsh/logisim-evolution"
SRC_URI="https://github.com/kevinawalsh/logisim-evolution/archive/${NUM}.zip -> ${P}.zip"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="amd64 x86"
IUSE="java nls"

DEPEND=">=virtual/jdk-1.9"
RDEPEND=">=virtual/jre-1.9 ${DEPEND}"

S="${WORKDIR}/logisim-evolution-${NUM}"

src_compile() {
	# Remove ALL .class and .jar files
	ant cleanall
	# Build logisim-evolution.jar
	ant jar || die "could not compile .jar"
}

src_install() {
	java-pkg_newjar logisim-evolution.jar logisim-evolution.jar
	java-pkg_dojar logisim-evolution.jar
	java-pkg_dolauncher logisim-evolution -jar logisim-evolution.jar
}
