# Copyright 2016-2017 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2

EAPI=6
inherit rindeal

GH_RN="github:shundhammer"

inherit git-hosting
inherit qmake-utils
inherit xdg

DESCRIPTION="GUI app to show where your disk space has gone and to help you to clean it up"
LICENSE="GPL-2"

SLOT="0"

KEYWORDS="~amd64"
IUSE="doc"

CDEPEND="
	dev-qt/qtcore:5
	dev-qt/qtgui:5
	dev-qt/qtwidgets:5"
DEPEND="${CDEPEND}"
RDEPEND="${CDEPEND}"

inherit arrays

src_prepare() {
	eapply_user
	xdg_src_prepare

	# no debug CXXFLAGS
	sed -e '/CONFIG.*=.* debug/d' -i -- src/src.pro || die

	if ! use doc ; then
		sed -e '/SUBDIRS/ s| doc||' -i -- qdirstat.pro || die
	fi
}

src_configure() {
	eqmake5
}

src_install() {
	emake INSTALL_ROOT="${ED}" install

	einstalldocs
	dodoc doc/cache-file-format.txt
}
