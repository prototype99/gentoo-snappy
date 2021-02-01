# Copyright 1999-2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

PYTHON_COMPAT=( python3_{6..9} )
inherit autotools python-single-r1 multilib multilib-minimal

DESCRIPTION="Standalone file import filter library for spreadsheet documents"
HOMEPAGE="https://gitlab.com/orcus/orcus/blob/master/README.md"

SRC_URI="https://kohei.us/files/orcus/src/${P}.tar.xz"
KEYWORDS="amd64 ~arm arm64 ~ppc ~ppc64 x86"

LICENSE="MIT"
SLOT="0/0.16" # based on SONAME of liborcus.so
IUSE="python +spreadsheet-model static-libs tools"

REQUIRED_USE="python? ( ${PYTHON_REQUIRED_USE} )"

RDEPEND="
	dev-libs/boost:=[${MULTILIB_USEDEP},zlib(+)]
	sys-libs/zlib[${MULTILIB_USEDEP}]
	python? ( ${PYTHON_DEPS} )
	spreadsheet-model? ( dev-libs/libixion:${SLOT}[${MULTILIB_USEDEP}] )
"
DEPEND="${RDEPEND}
	dev-util/mdds:1/1.5
"

pkg_setup() {
	use python && python-single-r1_pkg_setup
}

src_prepare() {
	gcc-major-version >= 11 && PATCHES=( "${FILESDIR}/${P}-gcc11.patch" ) # bug 764035
	default
	eautoreconf
}

multilib_src_configure() {
	econf \
		--disable-werror \
		$(use_enable python) \
		$(use_enable spreadsheet-model) \
		$(use_enable static-libs static) \
		$(use_with tools)
}

multilib_src_install() {
	default
	find "${D}" -name '*.la' -type f -delete || die
}
