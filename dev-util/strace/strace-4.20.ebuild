# Copyright 1999-2016 Gentoo Foundation
# Copyright 2017-2018 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2

EAPI=6
inherit rindeal

## git-hosting.eclass:
GH_RN="github"
GH_REF="v${PV}"

## EXPORT_FUNCTIONS: src_unpack
## variables: GH_HOMEPAGE
inherit git-hosting
## functions: append-ldflags
inherit flag-o-matic
## functions: tc-export_build_env
inherit toolchain-funcs
## functions: eautoreconf
inherit autotools

DESCRIPTION="Useful diagnostic, instructional, and debugging tool"
HOMEPAGE="https://strace.io/ ${GH_HOMEPAGE} https://sourceforge.net/projects/strace/"
LICENSE="BSD"

SLOT="0"

KEYWORDS="~amd64 ~arm ~arm64"
IUSE_A=( aio perl static unwind test )

LIB_DEPEND="unwind? ( sys-libs/libunwind[static-libs(+)] )"
# strace only uses the header from libaio to decode structs
CDEPEND_A=()
DEPEND_A=( "${CDEPEND_A[@]}"
	"static? ( ${LIB_DEPEND} )"
	"aio? ( >=dev-libs/libaio-0.3.106 )"
	"sys-kernel/linux-headers"
)
RDEPEND_A=( "${CDEPEND_A[@]}"
	"!static? ( ${LIB_DEPEND//\[static-libs(+)]} )"
	"perl? ( dev-lang/perl )"
)

inherit arrays

src_prepare() {
	eapply_user

	rsed -e '/autoreconf/ s|^|## PORTAGE ##|' -i -- bootstrap

	./bootstrap || die

	eautoreconf

	# Stub out the -k test since it's known to be flaky. #545812
	rsed -e '1iexit 77' -i -- tests*/strace-k.test
}

src_configure() {
	use static && append-ldflags -static

	export ac_cv_header_libaio_h=$(usex aio)

	# Set up the default build settings, and then use the names strace expects
	tc-export_build_env BUILD_{CC,CPP}
	local v bv
	for v in CC CPP {C,CPP,LD}FLAGS ; do
		bv="BUILD_${v}"
		export "${v}_FOR_BUILD=${!bv}"
	done

	econf $(use_with unwind libunwind)
}

src_install() {
	default

	newdoc CREDITS{.in,}
	# empty
	rrm "${ED}"/usr/share/doc/${PF}/AUTHORS

	use perl || rrm "${ED}"/usr/bin/strace-graph
}
