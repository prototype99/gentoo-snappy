# Copyright 1999-2015 Gentoo Foundation
# Copyright 2016-2018 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2

EAPI=6
inherit rindeal

## git-hosting.eclass:
GH_RN="github:xiph"

## EXPORT_FUNCTIONS: src_unpack
## variables: GH_HOMEPAGE
inherit git-hosting
## functions: eautoreconf
inherit autotools
## functions: prune_libtool_files
inherit ltprune

DESCRIPTION="Free lossless audio encoder and decoder"
HOMEPAGE="https://xiph.org/flac/ ${GH_HOMEPAGE}"
LICENSE="BSD FDL-1.2 GPL-2 LGPL-2.1"

SLOT="0"

KEYWORDS="amd64 arm arm64"
IUSE_A=( altivec +cxx debug doc examples ogg cpu_flags_x86_sse static-libs test )

CDEPEND_A=(
	"ogg? ( media-libs/libogg )"
)
DEPEND_A=( "${CDEPEND_A[@]}"
	"app-arch/xz-utils"
	"sys-devel/gettext"
	"virtual/pkgconfig"
)
RDEPEND_A=( "${CDEPEND_A[@]}" )

inherit arrays

src_prepare() {
	eapply "${FILESDIR}"/1.3.0-dont_build_tests.patch
	eapply "${FILESDIR}"/1.3.2-configure_ac_flags.patch
	eapply "${FILESDIR}"/1.3.2-LTLIBICONV.patch
	eapply "${FILESDIR}"/1.3.2-honor_html_dir.patch
	eapply_user

	use doc || rsed -e '/SUBDIRS/ s|html||' -i -- doc/Makefile.am
	# https://sourceforge.net/p/flac/bugs/379/
	find doc/ -type f -name Makefile.am | xargs sed \
		-e 's|docdir = $(datadir)/doc/$(PACKAGE)-$(VERSION)|docdir = @docdir@|' -i --
	assert
	# delete doxygen tagfile
	rsed -e 's|FLAC.tag||g' -e '/doc_DATA =/d' -i -- doc/Makefile.am

	rsed -r -e '/^SUBDIRS/ s, microbench( |$), ,' -i -- Makefile.am
	use examples || rsed -r -e '/^SUBDIRS/ s, examples( |$), ,' -i -- Makefile.am
	if ! use test ; then
		rsed -r -e '/^SUBDIRS/ s, test( |$), ,' -i -- Makefile.am
		rsed -r -e '/(^|[ \t])test_.*\\$/d' -i -- src/Makefile.am
	fi

	touch config.rpath || die
	AT_M4DIR="m4" \
		eautoreconf
}

src_configure() {
	local econf_args=(
		--docdir="${EPREFIX}"/usr/share/doc/${PF}
		--disable-doxygen-docs
		--disable-xmms-plugin
		--disable-thorough-tests

		$(use_enable altivec)
		$(use_enable cpu_flags_x86_sse sse)
		$(use_enable cxx cpplibs)
		$(use_enable debug)
		$(use_enable ogg)
	)
	econf "${econf_args[@]}"
}

src_test() {
	if [[ ${UID} != 0 ]]; then
		default
	else
		ewarn "Tests will fail if ran as root, skipping."
	fi
}

src_install() {
	default

	prune_libtool_files --all
}
