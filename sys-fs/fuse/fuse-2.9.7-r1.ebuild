# Copyright 1999-2018 Gentoo Foundation
# Copyright 2018 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2

EAPI=6
inherit rindeal

## git-hosting.eclass:
GH_RN="github:libfuse:libfuse"
GH_REF="fuse-${PV}"

## EXPORT_FUNCTIONS: pkg_setup
inherit linux-info

## EXPORT_FUNCTIONS: src_unpack
inherit git-hosting

## functions: eautoreconf
inherit autotools

## functions: prune_libtool_files
inherit ltprune

## functions: get_udevdir
inherit udev

DESCRIPTION="An interface for filesystems implemented in userspace"
LICENSE="GPL-2"

SLOT="0"

KEYWORDS="~amd64 ~arm ~arm64"
IUSE_A=( examples static-libs )

CDEPEND_A=()
DEPEND_A=( "${CDEPEND_A[@]}"
	"virtual/pkgconfig"
)
RDEPEND_A=( "${CDEPEND_A[@]}"
	"sys-fs/fuse-common"
)

inherit arrays

CONFIG_CHECK="~FUSE_FS"
FUSE_FS_WARNING="You need to have FUSE module built to use user-mode utils"

src_prepare() {
	eapply "${FILESDIR}"/${PN}-2.9.3-kernel-types.patch
	eapply_user

	# sandbox violation with mtab writability wrt #438250
	rsed -r -e 's|^[ \t]*umount --fake.*|true|' -i -- configure.ac

	touch config.rpath
	eautoreconf
}

src_configure() {
	local my_econf_args=(
		UDEV_RULES_PATH="${EPREFIX}/$(get_udevdir)/rules.d"

		$(use_enable static-libs static)
		--disable-example
		--enable-lib
		--enable-util
		--disable-rpath
		--with-gnu-ld
	)
	econf "${my_econf_args[@]}"
}

src_install() {
	local DOCS=( AUTHORS ChangeLog README.md README.NFS NEWS doc/how-fuse-works doc/kernel.txt )
	default

	prune_libtool_files

	if use examples ; then
		docinto examples
		dodoc example/*
	fi

	### installed via fuse-common
	rrm -r "${ED%/}"/{etc,$(get_udevdir)}

	rrm "${ED%/}"/sbin/mount.fuse*
	rrm "${ED%/}"/usr/share/man/man8/mount.fuse*

	### handled by the device manager
	rrm -r "${D%/}"/dev
}
