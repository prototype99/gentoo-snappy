# Copyright 1999-2017 Gentoo Foundation
# Copyright 2018-2019 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2

EAPI=7
inherit rindeal

## git-hosting.eclass:
GH_RN="github:clbr"
GH_REF="v${PV}"

## EXPORT_FUNCTIONS: src_unpack
inherit git-hosting

## EXPORT_FUNCTIONS: pkg_setup
inherit linux-info

DESCRIPTION="Utility to view Radeon GPU utilization"
LICENSE="GPL-3"

SLOT="0"

KEYWORDS="~amd64"
IUSE_A=( amdgpu xcb )

CDEPEND_A=(
	"x11-libs/libpciaccess:0"
	"x11-libs/libdrm:0"
	"xcb? ( x11-libs/libxcb:0 )"
	"sys-libs/ncurses:0="
	"amdgpu? ( x11-libs/libdrm:0[video_cards_amdgpu] )"
)
DEPEND_A=( "${CDEPEND_A[@]}"
	"virtual/pkgconfig"
)
RDEPEND_A=( "${CDEPEND_A[@]}" )

inherit arrays

MY_XCBLIB_DIR="/usr/libexec"

pkg_setup() {
	if use amdgpu
	then
		local -a CONFIG_CHECK_A=(
			"~DEVMEM"
		)
		local -- CONFIG_CHECK="${CONFIG_CHECK_A[*]}"
		linux-info_pkg_setup
	fi
}

src_prepare() {
	eapply_user

	rsed -e "/dlopen(/ s|\"\(libradeontop_xcb.so\)\"|\"${EPREFIX}${MY_XCBLIB_DIR}/\1\"|" -i -- auth.c

	cat > include/version.h <<-_EOF_ || die
		#ifndef VER_H
		# define VER_H

		# define VERSION "${PV}"

		#endif
	_EOF_
}

src_compile() {
	local -a emake_cmd=(
		emake

		# Do not add -g or -s to CFLAGS
		plain=1

		amdgpu=$(usex amdgpu 1 0)
		xcb=$(usex xcb 1 0)
		nls=0  # I don't bother implementing this
	)
	echo "${emake_cmd[@]}"
	"${emake_cmd[@]}"
}

src_install() {
	if use xcb
	then
		dobin "${PN}"
		exeinto "${MY_XCBLIB_DIR}"
		doexe "libradeontop_xcb.so"
	else
		dosbin "${PN}"
	fi

	doman "${PN}.1"
	einstalldocs
}
