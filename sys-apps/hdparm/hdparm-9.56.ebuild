# Copyright 1999-2016 Gentoo Foundation
# Copyright 2016-2018 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2

EAPI=6
inherit rindeal

## functions: append-ldflags
inherit flag-o-matic

DESCRIPTION="Utility to change hard drive performance parameters"
HOMEPAGE="https://sourceforge.net/projects/${PN}/"
LICENSE="BSD GPL-2" # GPL-2 only

SLOT="0"
SRC_URI="mirror://sourceforge/${PN}/${P}.tar.gz"

KEYWORDS="~amd64 ~arm ~arm64"
IUSE_A=( static )

inherit arrays

src_prepare() {
	eapply "${FILESDIR}"/9.28-wiper_sh_max_ranges.patch
	eapply "${FILESDIR}"/9.43-fallocate_close_fd.patch
	eapply "${FILESDIR}"/9.43-fix_zero_div_in_get_geom.patch
	eapply "${FILESDIR}"/9.43-fix-bashisms.patch
	eapply "${FILESDIR}"/9.48-fix_memleak_strdup.patch
	eapply "${FILESDIR}"/9.48-wiper_warn.patch
	eapply "${FILESDIR}"/9.56-quiet_security_freeze.patch
	eapply_user

	local sed_args=(
		# no strip
		-e '/STRIP/d'
		# respect CC
		-e '/^CC/d'
		# respect CFLAGS
		-e "/^CFLAGS/ s|-O2||"
		# respect LDFLAGS
		-e "/^LDFLAGS/d"
	)
	rsed "${sed_args[@]}" -i -- Makefile
}

src_configure() {
	use static && append-ldflags -static
}

src_install() {
	DOCS=( hdparm.lsm Changelog README.acoustic hdparm-sysconfig )
	default

	doman "${PN}.8"

	# contrib/{idectl,ultrabayd} are terribly outdated, even debian doesn't install them
	insinto "/usr/share/${PN}/contrib"
	doins contrib/fix_standby*

	insinto "/usr/share/${PN}/wiper"
	doins -r wiper/*
}
