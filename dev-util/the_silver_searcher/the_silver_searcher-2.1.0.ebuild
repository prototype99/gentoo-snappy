# Copyright 1999-2016 Gentoo Foundation
# Copyright 2017 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2

EAPI=6
inherit rindeal

GH_RN="github:ggreer"

inherit git-hosting
inherit autotools
inherit bash-completion-r1

DESCRIPTION="A code-searching tool similar to ack, but faster"
LICENSE="Apache-2.0"

SLOT="0"

KEYWORDS="~amd64 ~arm ~arm64"
IUSE_A=(
	+lzma # https://github.com/ggreer/the_silver_searcher/pull/1148
	test
	zlib
)

CDEPEND_A=(
	"dev-libs/libpcre"
	"lzma? ( app-arch/xz-utils )"
	"zlib? ( sys-libs/zlib )"
)
DEPEND_A=( "${CDEPEND_A[@]}"
	"virtual/pkgconfig"
	"test? ( dev-util/cram )"
)
RDEPEND_A=( "${CDEPEND_A[@]}"
	"!sys-apps/${PN}"
)

inherit arrays

src_prepare() {
	default

	sed -e '/^dist_bashcomp/d' -i -- Makefile.am || die

	eautoreconf
}

src_configure() {
	local econf_opts=(
		$(use_enable lzma)
		$(use_enable zlib)
	)
	econf "${econf_opts[@]}"
}

src_test() {
	cram -v tests/*.t || die "tests failed"
}

src_install() {
	default

	newbashcomp ag.bashcomp.sh ag
}
