# Copyright 2016-2019 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2

EAPI=7
inherit rindeal

## gitlab.eclass:
GITLAB_NS="rindeal-ns/mirrors"
GITLAB_REF="v${PV}"

## functions: gitlab:src_unpack
## variables: GITLAB_SRC_URI
inherit gitlab

## functions: eautoreconf
inherit autotools

## functions: doicon
inherit desktop

DESCRIPTION="Audio spectrum analyser in 3D"
HOMEPAGE_A=(
	"http://spectrum3d.sourceforge.net"
	"https://sourceforge.net/projects/spectrum3d/"
)
LICENSE_A=(
	"GPL-3"
)

SLOT="0"
SRC_URI_A=(
	"${GITLAB_SRC_URI}"
)

KEYWORDS="~amd64"
IUSE_A=( gtk3 sdl jack )

CDEPEND_A=(
	"gtk3? ( x11-libs/gtk+:3 )"
	"!gtk3? ( x11-libs/gtk+:2 )"

	"sdl? ( media-libs/libsdl )"
	"!sdl? ( media-libs/libsdl2 )"

	# libGL, libGLU
	"virtual/opengl"

	# gstreamer-1.0
	"media-libs/gstreamer:1.0"

	"jack? ( virtual/jack )"
)
DEPEND_A=( "${CDEPEND_A[@]}" )
RDEPEND_A=( "${CDEPEND_A[@]}"
	# equalizer-nbands, audiochebband, jackaudiosrc, spectrum, wavenc, jackaudiosink, autoaudiosink
	"media-libs/gst-plugins-good:1.0"
	# alsasrcm, playbin, audioconvert, audiotestsrc
	"media-libs/gst-plugins-base:1.0"
)

inherit arrays

src_unpack() {
	gitlab:src_unpack
}

src_prepare() {
	default

	# .desktop contains duplicated Type= (https://sourceforge.net/p/spectrum3d/discussion/bug-wishlist/thread/d429f757/)
	gawk -i inplace '!seen[$0]++' "data/${PN,,}.desktop.in" || die

	## fix icons path (https://sourceforge.net/p/spectrum3d/discussion/bug-wishlist/thread/8c685767/)
	# the svg icon is used only in the desktop menu entry
	rsed -r -e "s|^(svgicondir =).*|\1 \$(datadir)/icons/hicolor/scalable/apps|" -i -- data/Makefile.am

	rsed -e "1s|^|icondir = \$(datadir)/${PN}/icons\n|" -i -- src/Makefile.am
	rsed -r -e "s|^(icondir =).*|\1 \$(datadir)/${PN}/icons|" -i -- data/Makefile.am
	# pass $(icondir) to source files
	rsed -e "/^AM_CPPFLAGS =/ s|$| -D ICONDIR='\"\$(icondir)\"'|" -i -- src/Makefile.am
	grep --files-with-matches -r "g_build_filename.*DATADIR.*icons" |\
		xargs \
		sed -r -e '/g_build_filename.*DATADIR.*icons/ '"s|DATADIR, \"icons\"|ICONDIR|" -i --

	eautoreconf
}

src_configure() {
	local myeconfargs=(
		$(use_enable gtk3)
		$(use_enable '!gtk3' gtk2)
		$(use_enable sdl)
		$(use_enable '!sdl' sdl2)
		$(use_enable jack)

	)
	econf "${myeconfargs[@]}"
}

src_install() {
	default

	# 44x44
	doicon data/${PN,,}.png
}
