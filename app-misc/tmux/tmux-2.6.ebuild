# Copyright 1999-2017 Gentoo Foundation
# Copyright 2017 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2

EAPI=6
inherit rindeal

## git-hosting.eclass:
GH_RN="github"

## EXPORT_FUNCTIONS: src_unpack
## variables: GH_HOMEPAGE
inherit git-hosting
## functions: eautoreconf
inherit autotools

DESCRIPTION="Terminal multiplexer"
HOMEPAGE="https://tmux.github.io/ ${GH_HOMEPAGE}"
LICENSE="ISC"

SLOT="0"

KEYWORDS="~amd64 ~arm ~arm64"
IUSE_A=( debug selinux utempter utf8proc static )

CDEPEND_A=(
	"dev-libs/libevent:0="
	">=dev-libs/libevent-2.1.5-r4"
	"utempter? ( sys-libs/libutempter )"
	"utf8proc? ( dev-libs/utf8proc )"
	"sys-libs/ncurses:0="
)
DEPEND_A=( "${CDEPEND_A[@]}"
	"virtual/pkgconfig"
)
RDEPEND_A=( "${CDEPEND_A[@]}"
	"dev-libs/libevent:="
	"selinux? ( sec-policy/selinux-screen )"
)

inherit arrays

src_prepare() {
	eapply_user

	sed -r -e '/^(AM_)?CFLAGS/ s, -(O[0-3]|g), ,g' -i -- Makefile.am || die

	eautoreconf
}

src_configure() {
	local my_econf_args=(
		# configure.ac overrides it otherwise
		--sysconfdir="${EPREFIX}"/etc

		$(use_enable debug)
		$(use_enable static)

		$(use_enable utempter)
		$(use_enable utf8proc)
	)
	econf "${my_econf_args[@]}"

}

src_install() {
	default

	dodoc example_tmux.conf

	insinto /usr/share/vim/vimfiles/ftdetect
	doins "${FILESDIR}"/tmux.vim
}
