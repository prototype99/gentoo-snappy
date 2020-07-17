# Copyright 2017-2019 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2

EAPI=7
inherit rindeal

## gitlab.eclass:
GITLAB_NS="gnuwget"
GITLAB_REF="${P}"

## functions: dsf:eval
inherit dsf-utils

## functions:  rindeal:prefix_flags
inherit rindeal-utils

## functions: gitlab:src_unpack
## variables: GITLAB_HOMEPAGE, GITLAB_SRC_URI
inherit gitlab

## functions: eautoreconf
inherit autotools

## functions: prune_libtool_files
inherit ltprune

DESCRIPTION="Successor of GNU Wget, a file and recursive website downloader."
HOMEPAGE_A=( "${GITLAB_HOMEPAGE}" )
LICENSE_A=(
	"GPL-3+"  # wget2
	"LGPL-3+" # libwget
)

SLOT="0"
SRC_URI_A=( "${GITLAB_SRC_URI}" )

KEYWORDS="~amd64 ~arm ~arm64"
IUSE_A=(
	nls static-libs assert xattr doc test
	+openssl +gnutls

	$(rindeal:prefix_flags 'compression_' \
		bzip2 +zlib lzma brotli)

	+libpsl
	nghttp2
	libidn libidn2
	libpcre libpcre2
	plugin-support
	gpgme
)

CDEPEND_A=(
	"nls? ( sys-devel/gettext )"

	"compression_bzip2? ( app-arch/bzip2:0 )"
	"compression_zlib? ( sys-libs/zlib:0 )"
	"compression_lzma? ( app-arch/xz-utils:0 )"
	"compression_brotli? ( app-arch/brotli:0 )"

	"openssl? ( dev-libs/openssl:0 )"
	"gnutls? ( net-libs/gnutls:0 )"
	"nghttp2? ( net-libs/nghttp2:0 )"
	"libpsl? ( net-libs/libpsl:0 )"

	"libidn? ( net-dns/libidn:0 )"
	"libidn2? ( net-dns/libidn2:0 )"

	"libpcre? ( dev-libs/libpcre:3 )"
	"libpcre2? ( dev-libs/libpcre2:0 )"

	"$(dsf:eval \
		'libidn|libidn2' \
			'virtual/libiconv' )"

	"gpgme? ( app-crypt/gpgme )"
)
DEPEND_A=( "${CDEPEND_A[@]}"
	"dev-libs/gnulib"
	"sys-devel/flex"
	"test? ( net-libs/libmicrohttpd )"
	"virtual/pkgconfig"
	"sys-devel/libtool"
	"doc? ("
		"app-doc/doxygen"
		"|| ("
			"app-text/pandoc-bin"
			"app-text/pandoc"
		")"
	")"
)
RDEPEND_A=( "${CDEPEND_A[@]}" )

REQUIRED_USE_A=(
	"?? ( libidn libidn2 )"
	"?? ( libpcre libpcre2 )"
)

inherit arrays

src_unpack() {
	gitlab:src_unpack
}

src_prepare() {
	eapply_user

	# lzip is only needed for tarball generation
	rsed -e "/^lzip/d" -i -- bootstrap.conf

	rsed -e "/^SUBDIRS/ s|\bexamples\b||" -i -- Makefile.am

	rsed -e "/^bin_PROGRAMS/ s|wget2_noinstall||" -e "/^wget2_noinstall/d" -i -- src/Makefile.am

	./bootstrap --no-git --gnulib-srcdir="${EPREFIX}"/usr/share/gnulib $(usex nls '' '--skip-po') || die

	eautoreconf
}

src_configure() {
	local my_econf_args=(
		--disable-rpath
		$(use_enable static-libs static)
		$(use_enable assert)
		$(use_enable nls)
		$(use_enable doc)
		$(use_enable xattr)

		$(use_with openssl)
		$(use_with gnutls)
		$(use_with libpsl)
		$(use_with nghttp2 libnghttp2)

		$(use_with {compression_,}bzip2)
		$(use_with {compression_,}zlib)
		$(use_with {compression_,}lzma)
		$(use_with compression_brotli brotlidec)

		$(use_with libidn2)
		$(use_with libidn)
		$(use_with libpcre2)
		$(use_with libpcre)
		$(use_with test libmicrohttpd) # build tests requiring libmicrohttpd
		$(use_with plugin-support)
		$(use_with gpgme)
	)

	econf "${my_econf_args[@]}"
}

src_install() {
	emake DESTDIR="${D}" install

	einstalldocs

	prune_libtool_files
}
