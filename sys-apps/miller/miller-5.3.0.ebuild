# Copyright 1999-2016 Gentoo Foundation
# Copyright 2016-2018 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2

EAPI=6
inherit rindeal

## git-hosting.eclass:
GH_RN="github:johnkerl"
GH_REF="v${PV}"

## EXPORT_FUNCTIONS: src_unpack
inherit git-hosting
## function: eautoreconf
inherit autotools

DESCRIPTION="Tool like sed, awk, cut, join, and sort for name-indexed data (CSV, JSON, ..)"
HOMEPAGE="https://johnkerl.org/miller ${GH_HOMEPAGE}"
LICENSE="BSD-2"

SLOT="0"

KEYWORDS="~amd64 ~arm ~arm64"
IUSE_A=( doc test )

DEPEND_A=(
	"sys-devel/flex"
)

inherit arrays

my_for_each_test_dir() {
	local test_dirs=( c/{reg,unit}_test )
	if use test ; then
		for d in "${test_dirs[@]}" ; do
			rpushd "${d}"
			"${@}" || die
			rpopd
		done
	fi
}

src_prepare() {
	default

	local sed_args=(
		# respect FLAGS
		-e '/.*FLAGS[^=]*=/ s:(-g|-pg|-O[0-9]) ::g'
	)
	find -type f -name "Makefile.am" | xargs sed -r "${sed_args[@]}" -i --
	assert

	# disable docs rebuilding as they're shipped prebuilt
	rsed -e '/SUBDIRS[^=]*=/ s:doc::g' -i -- Makefile.am

	# disable building tests automagically
	use test || rsed -e '/SUBDIRS[^=]*=/ s:[^ ]*_test::g' -i -- c/Makefile.am

	eautoreconf
}

src_test() {
	my_for_each_test_dir emake check
}

src_install() {
	local HTML_DOCS=( $(usev doc) )

	default

	doman 'doc/mlr.1'
}
