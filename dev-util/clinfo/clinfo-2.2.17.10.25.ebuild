# Copyright 2017 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2

EAPI=6
inherit rindeal

GH_RN="github:Oblomov"

inherit git-hosting

DESCRIPTION="Tool to display info about the system's OpenCL capabilities"
LICENSE="CC0-1.0"

SLOT="0"

KEYWORDS="~amd64"

IUSE_A=( )

CDEPEND_A=(
	"virtual/opencl"
)
DEPEND_A=( "${CDEPEND_A[@]}" )
RDEPEND_A=( "${CDEPEND_A[@]}" )

inherit arrays

PATCHES=(
	"${FILESDIR}"/2.2.17.10.25-CFLAGS.patch
)

src_install() {
	local emake_args=(
		MANDIR="${ED}"/usr/share/man
		PREFIX="${ED}"/usr
		install
	)
	emake "${emake_args[@]}"
}
