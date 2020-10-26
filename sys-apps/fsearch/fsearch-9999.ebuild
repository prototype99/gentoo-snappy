# Copyright 2016 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2

EAPI=6

GH_RN="github:cboxdoerfer"

inherit rindeal git-hosting autotools xdg

DESCRIPTION="Fast file search utility for GNU/Linux based on GTK+3"
HOMEPAGE="https://cboxdoerfer.github.io/fsearch/ ${HOMEPAGE}"
LICENSE="GPL-2+"

SLOT="0"

KEYWORDS="~amd64 ~arm"
IUSE="debug"

CDEPEND="
	>=x11-libs/gtk+-3.12:3
	>=dev-libs/glib-2.36:2
	dev-libs/libpcre"
DEPEND="${CDEPEND}
	sys-devel/gettext
	virtual/pkgconfig"
RDEPEND="${CDEPEND}"

src_prepare() {
	eapply_user

	# respect flags
	sed -r -e '/^CFLAGS/ s|-O[^ \t"]*||g' -i -- configure.ac || die
	# https://github.com/cboxdoerfer/fsearch/pull/13
	sed -e '/AM_CONDITIONAL(DEBUG/ s|text |test |' -i -- configure.ac || die
	# https://github.com/cboxdoerfer/fsearch/issues/14
	sed -e 's|g_assert (num_items > 0);|g_assert (num_items >= 0);|' -i -- src/array.c || die

	eautoreconf
}

src_configure() {
	local myeconfargs=(
		$(use_enable debug)
	)

	econf "${myeconfargs[@]}" || die
}
