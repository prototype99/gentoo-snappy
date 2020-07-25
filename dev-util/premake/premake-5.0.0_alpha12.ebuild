# Copyright 2016-2018 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2

EAPI=6
inherit rindeal

## functions: append-ldflags
inherit flag-o-matic
## functions: tc-getPKG_CONFIG
inherit toolchain-funcs

MY_PV="${PV//_/-}"
MY_P="${PN}-${MY_PV}"

DESCRIPTION="Powerfully simple build configuration"
HOMEPAGE="https://premake.github.io/"
LICENSE="BSD"
SRC_URI="https://github.com/premake/premake-core/releases/download/v${MY_PV}/${MY_P}-src.zip"

SLOT="5"
KEYWORDS="~amd64 ~arm"
IUSE=""

CDEPEND_A=(
	"dev-libs/openssl:0"
)
DEPEND_A=( "${CDEPEND_A[@]}"
	"virtual/pkgconfig"
)
RDEPEND_A=( "${CDEPEND_A[@]}" )

inherit arrays

S="${WORKDIR}/${MY_P}"
build_dir="${S}/build/gmake.unix"

src_configure() {
	append-ldflags $( $(tc-getPKG_CONFIG) --libs-only-l openssl )
}

src_compile() {
	cd "${build_dir}" || die
	emake config=release verbose=1
}

src_install() {
	dobin 'bin/release/premake5'
	einstalldocs
}
