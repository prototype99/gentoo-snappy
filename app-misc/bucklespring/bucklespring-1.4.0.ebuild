# Copyright 2016-2018 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2

EAPI=6
inherit rindeal

## git-hosting.eclass:
GH_RN="github:zevv"

## EXPORT_FUNCTIONS: src_unpack
inherit git-hosting
## functions: tc-getCC
inherit toolchain-funcs
## functions: systemd_douserunit, systemd_get_userunitdir
inherit systemd
## functions: rindeal:expand_vars
inherit rindeal-utils
## functions: dohelp2man
inherit help2man

DESCRIPTION="Nostalgia bucklespring keyboard (IBM Model-M) sound emulator"
LICENSE="GPL-2"

SLOT="0"

KEYWORDS="~amd64 ~x86"
IUSE_A=( doc )

CDEPEND_A=(
	"media-libs/openal"
	"media-libs/alure"
	"x11-libs/libX11"
	"x11-libs/libXtst"
)
DEPEND_A=( "${CDEPEND_A[@]}"
	"virtual/pkgconfig"
)
RDEPEND_A=( "${CDEPEND_A[@]}" )

inherit arrays

src_prepare() {
	# https://github.com/zevv/bucklespring/pull/27 https://github.com/zevv/bucklespring/pull/27
	# fixed in version >1.4.0
	eapply "${FILESDIR}/1.4.0-Makefile_flags.patch"
	eapply_user
}

src_configure() {
	declare -g -r -- BIN_NAME="buckle"

	export LD="$(tc-getCC)"

	## default directory to search for wav samples
	export PATH_AUDIO="${EPREFIX}/usr/share/${BIN_NAME}/wav"
}

src_install() {
	dobin "${BIN_NAME}"

	dohelp2man "${BIN_NAME}"
	einstalldocs

	insinto "${PATH_AUDIO##"${EPREFIX}"}"
	doins -r wav/*

	rindeal:expand_vars "${FILESDIR}/${BIN_NAME}.service.in" "${BIN_NAME}.service"
	rindeal:expand_vars "${FILESDIR}/${BIN_NAME}.service.conf.in" "${BIN_NAME}.service.conf"

	systemd_douserunit "${BIN_NAME}.service"
	insinto "$(systemd_get_userunitdir)/${BIN_NAME}.service.d"
	newins "${BIN_NAME}.service.conf" "00gentoo.conf"
}
