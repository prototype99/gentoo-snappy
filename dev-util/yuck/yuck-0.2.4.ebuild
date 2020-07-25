# Copyright 2016-2017 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2

EAPI=6
inherit rindeal

GH_RN="github:hroptatyr"
GH_REF="v${PV}"

inherit git-hosting
inherit autotools

DESCRIPTION="Your Umbrella Command Kit, a command line option parser for C"
LICENSE="BSD"

SLOT="0"

KEYWORDS="~amd64 ~arm ~arm64"

src_prepare() {
	default

	eautoreconf
}
