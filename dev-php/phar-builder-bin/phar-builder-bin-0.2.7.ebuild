# Copyright 2018 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2

EAPI=6
inherit rindeal

DESCRIPTION="Create Phar of Composer based PHP application "
HOMEPAGE="https://github.com/MacFJA/PharBuilder"
LICENSE="MIT"

PN_NB="${PN%-bin}"
DISTFILE="phar-builder-${PV}.phar"

SLOT="0"
SRC_URI="https://github.com/MacFJA/PharBuilder/releases/download/${PV}/phar-builder.phar -> ${DISTFILE}"

KEYWORDS="~amd64 ~arm ~arm64"
IUSE_A=( )

CDEPEND_A=()
DEPEND_A=( "${CDEPEND_A[@]}" )
RDEPEND_A=( "${CDEPEND_A[@]}" )

REQUIRED_USE_A=(  )
RESTRICT+=" mirror"

inherit arrays

S="${WORKDIR}"

src_unpack() {
	rcp "${DISTDIR}/${DISTFILE}" "${PN_NB}"
}

src_configure() { : ; }
src_compile() { : ; }

src_install() {
	local inst_dir="/opt/${PN_NB}"
	into "${inst_dir}"
	dobin "${PN_NB}"
	dosym "${inst_dir}/bin/${PN_NB}" /usr/bin/${PN_NB}
}
