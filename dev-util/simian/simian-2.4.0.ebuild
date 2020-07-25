# Copyright 2016 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2

EAPI=6

JAVA_PKG_IUSE="doc"

inherit java-pkg-2

DESCRIPTION="Similarity analyser that identifies duplication in the source code"
HOMEPAGE="http://www.harukizaemon.com/simian/index.html"
LICENSE="simian"
SRC_URI="http://www.harukizaemon.com/${PN}/${P}.tar.gz"

RESTRICT="mirror strip"
SLOT="0"
KEYWORDS="~amd64"

DEPEND=""
RDEPEND="|| ( >=virtual/jre-1.8 >=virtual/jdk-1.8 )"

S="${WORKDIR}"

# do not remove this function as java-pkg-2 doesn't call default()
src_prepare() {
	default
}

src_install() {
	java-pkg_newjar "bin/${P}.jar" "${PN}.jar"
	java-pkg_dolauncher

	use doc && java-pkg_dojavadoc 'javadoc'
	HTML_DOCS=( {changes,features}.html )
	DOCS=( ${PN}.{dtd,xsl} )
	einstalldocs
}
