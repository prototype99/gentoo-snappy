# Copyright 1999-2017 Gentoo Foundation
# Copyright 2017-2018 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2

EAPI=6
inherit rindeal

## git-hosting.eclass:
GH_RN="github:xiph:vorbis"
GH_REF="v${PV}"

## EXPORT_FUNCTIONS: src_unpack
## variables: GH_HOMEPAGE
inherit git-hosting
## functions: eautoreconf
inherit autotools
## functions: prune_libtool_files
inherit ltprune

DESCRIPTION="Ogg Vorbis sound file format library"
HOMEPAGE="https://xiph.org/vorbis/ ${GH_HOMEPAGE}"
LICENSE="BSD"

# TODO: subslots could be based on lib sonames
SLOT="0"

KEYWORDS="amd64 arm arm64"
IUSE_A=( static-libs doc examples oggtest )

CDEPEND_A=(
	">=media-libs/libogg-1.3.0"
)
DEPEND_A=( "${CDEPEND_A[@]}"
	"app-arch/xz-utils"
	"virtual/pkgconfig"
)
RDEPEND_A=( "${CDEPEND_A[@]}" )

inherit arrays

src_prepare() {
	default

	rsed -r -e '/CFLAGS="/ s,( |")-(O3|ffast-math|mno-ieee-fp),\1,g' \
		-i -- configure.ac

	# Un-hack docdir redefinition.
	find -name 'Makefile.am' \
		-exec sed -i \
			-e 's:$(datadir)/doc/$(PACKAGE)-$(VERSION):@docdir@/html:' \
			{} + || die

	if ! use doc ; then
		rsed \
			-e '/^DISTCHECK_CONFIGURE_FLAGS/ s|--enable-docs|--disable-docs|' \
			-e '/^SUBDIRS/ s| doc| |' \
			-i -- Makefile.am
	fi

	AT_M4DIR="m4" \
		eautoreconf
}

src_configure() {
	local my_econf_args=(
		$(use_enable doc docs)
		$(use_enable static-libs static)
		$(use_enable examples)
		$(use_enable oggtest)
	)
	econf "${my_econf_args[@]}"
}

src_install() {
	default

	prune_libtool_files --all
}
