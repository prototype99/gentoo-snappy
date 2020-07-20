# Copyright 2016-2019 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2

EAPI=7
inherit rindeal

## python-*.eclass:
PYTHON_COMPAT=( python2_7 python3_{5,6,7} )

## git-hosting.eclass:
GH_RN="github:rockdaboot"
GH_REF="${PN}-${PV}"

## EXPORT_FUNCTIONS: src_unpack
inherit git-hosting

## functions: eautoreconf
inherit autotools

## EXPORT_FUNCTIONS: pkg_setup
inherit python-any-r1

## functions: dsf:eval
inherit dsf-utils

## functions: prune_libtool_files
inherit ltprune

DESCRIPTION="C library for the Publix Suffix List"
HOMEPAGE="${GH_HOMEPAGE} https://rockdaboot.github.io/${PN}"
LICENSE="MIT"

SLOT="0"
git-hosting_gen_snapshot_url "github:publicsuffix:list" "c45eff1" psl_list_url PSL_LIST_DISTFILE
SRC_URI+="
	${psl_list_url} -> ${PSL_LIST_DISTFILE}
"

KEYWORDS="amd64 arm arm64"
IUSE_A=( doc man static-libs nls +rpath
	+builtin +builtin_libicu builtin_libidn2 builtin_libidn
	+runtime +runtime_libicu runtime_libidn2 runtime_libidn
)

CDEPEND_A=(
	"$(dsf:eval \
		'(builtin & builtin_libicu) | (runtime & runtime_libicu)' \
			"dev-libs/icu[static-libs?]" )"
	"$(dsf:eval \
		'(builtin & builtin_libidn) | (runtime & runtime_libidn)' \
			"net-dns/libidn[static-libs?]" )"
	"$(dsf:eval \
		'(builtin & builtin_libidn2) | (runtime & runtime_libidn2)' \
			"net-dns/libidn2[static-libs?]" )"

	"${PYTHON_DEPS}"
)
DEPEND_A=( "${CDEPEND_A[@]}"
	"sys-devel/gettext"
	"virtual/pkgconfig"
	"sys-devel/libtool"

	"doc? ( dev-util/gtk-doc )"
	# xsltproc
	"man? ( dev-libs/libxslt )"
)
RDEPEND_A=( "${CDEPEND_A[@]}" )

REQUIRED_USE_A=(
	"builtin? ("
		"^^ ("
			"builtin_libicu"
			"builtin_libidn"
			"builtin_libidn2"
		")"
	")"
	"runtime? ("
		"^^ ("
			"runtime_libicu"
			"runtime_libidn"
			"runtime_libidn2"
		")"
	")"
)

inherit arrays

src_unpack() {
	git-hosting_src_unpack

	rrmdir "${S}/list"
	git-hosting_unpack "${DISTDIR}/${PSL_LIST_DISTFILE}" "${S}/list"
}

src_prepare() {
	default

	if ! use doc
	then
		## this copies ./autogen.sh
		rrm -f gtk-doc.make
		echo "EXTRA_DIST =" >gtk-doc.make || die
		echo "CLEANFILES =" >>gtk-doc.make || die
	fi

	eautoreconf
}

src_configure() {
	local myeconfargs=(
		--disable-cfi
		--disable-ubsan
		--disable-asan

		$(use_enable doc gtk-doc)
		$(use_enable doc gtk-doc-html)
		$(use_enable doc gtk-doc-pdf)
		$(use_enable man)
		$(use_enable static-libs static)
		$(use_enable nls)
		$(use_enable rpath)
	)
	econf "${myeconfargs[@]}"
}

src_install() {
	default

	exeinto /usr/libexec
	doexe src/psl-make-dafsa

	prune_libtool_files
}
