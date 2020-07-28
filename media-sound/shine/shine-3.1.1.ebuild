# Copyright 2017-2018 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2

EAPI=6
inherit rindeal

## git-hosting.eclass:
GH_RN="github:toots"

## EXPORT_FUNCTIONS: src_unpack
inherit git-hosting
## functions: eautoreconf
inherit autotools
## functions: prune_libtool_files
inherit ltprune

DESCRIPTION="Super fast fixed-point MP3 encoder"
LICENSE="LGPL-2.1"

SLOT="0"

KEYWORDS="~amd64 ~arm ~arm64"
IUSE_A=( static-libs )

CDEPEND_A=()
DEPEND_A=( "${CDEPEND_A[@]}" )
RDEPEND_A=( "${CDEPEND_A[@]}" )

inherit arrays

src_prepare() {
	default

	rsed -r -e '/^CFLAGS *=/ s,-funroll-loops|-O2,,g' -i -- Makefile.am

	eautoreconf
}

src_configure() {
	local my_econf_args=(
		$(use_enable static-libs static)
	)
	econf "${my_econf_args[@]}"
}

src_install() {
	default

	prune_libtool_files
}
