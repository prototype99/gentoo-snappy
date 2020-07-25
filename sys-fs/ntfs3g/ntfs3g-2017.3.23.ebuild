# Copyright 1999-2017 Gentoo Foundation
# Copyright 2017-2018 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2

EAPI=6
inherit rindeal

## functions: prune_libtool_files
inherit ltprune
## functions: linux-info_pkg_setup
inherit linux-info
## functions: udev_dorules
inherit udev
## functions: tc-ld-disable-gold
inherit toolchain-funcs
## functions: elibtoolize
inherit libtool

DESCRIPTION="Open source read/write NTFS driver for FUSE"
HOMEPAGE="https://www.tuxera.com/community/ntfs-3g-download/"
LICENSE="GPL-2"

# The subslot matches the SONAME major #.
SLOT="0/88"
MY_PN="${PN/3g/-3g}"
MY_P="${MY_PN}_ntfsprogs-${PV}"
SRC_URI="https://tuxera.com/opensource/${MY_P}.tgz"

KEYWORDS="amd64 arm arm64"
IUSE_A=(
	acl +external-fuse suid xattr

	debug ldscript pedantic really-static static-libs

	uuid hd

	+ntfs-3g +ntfsprogs +mount-helper library crypto extras
	mtab +device-default-io-ops
	quarantined
)

CDEPEND_A=(
	"!sys-fs/ntfsprogs"
	"crypto? ("
		">=dev-libs/libgcrypt-1.2.2:0"
		">=net-libs/gnutls-1.4.4"
	")"
	"external-fuse? ( >=sys-fs/fuse-2.8.0:0 )"
)
DEPEND_A=( "${CDEPEND_A[@]}"
	"sys-apps/attr"
	"virtual/pkgconfig"
)
RDEPEND_A=( "${CDEPEND_A[@]}" )

REQUIRED_USE_A=(
	"ntfsprogs? ( device-default-io-ops )"
)

inherit arrays

S="${WORKDIR}/${MY_P}"

pkg_setup() {
	if use external-fuse ; then
		CONFIG_CHECK="~FUSE_FS"
		FUSE_FS_WARNING="You need to have FUSE module built to use ntfs-3g"
		linux-info_pkg_setup
	fi
}

src_prepare() {
	eapply "${FILESDIR}"/${PN}-2014.2.15-no-split-usr.patch
	eapply "${FILESDIR}"/${PN}-2016.2.22-sysmacros.patch # gentoo#580136
	eapply_user

	# Keep the symlinks in the same place we put the main binaries.
	# Having them in / when all the progs are in /usr is pointless.
	rsed -e 's:/sbin:$(sbindir):g' \
		-i -- {ntfsprogs,src}/Makefile.in # gentoo#578336

	# Note: patches apply to Makefile.in, so don't run autotools here.
	elibtoolize
}

src_configure() {
	tc-ld-disable-gold

	local myeconfargs=(
		--prefix="${EPREFIX}"/usr
		--exec-prefix="${EPREFIX}"/usr
		--docdir="${EPREFIX}"/usr/share/doc/${PF}
		--disable-ldconfig # do not update cache

		$(use_enable debug)
		--enable-warnings # enable lots of compiler warnings
		$(use_enable pedantic)
		$(use_enable static-libs static)
		$(use_enable really-static)
		$(use_enable ldscript)

		$(use_enable mount-helper)
		$(use_enable library)
		$(use_enable mtab)
		$(use_enable acl posix-acls)
		$(use_enable xattr xattr-mappings)
		$(use_enable device-default-io-ops)
		$(use_enable ntfs-3g)
		$(use_enable ntfsprogs)
		$(use_enable quarantined)
		$(use_enable crypto)
		$(use_enable extras)

		--with-fuse=$(usex external-fuse external internal)
		$(use_with uuid)
		$(use_with hd)
	)

	econf "${myeconfargs[@]}"
}

src_install() {
	default

	use suid && fperms u+s "/usr/bin/${MY_PN}"
	udev_dorules "${FILESDIR}"/99-ntfs3g.rules
	prune_libtool_files

	dosym mount.ntfs-3g /usr/sbin/mount.ntfs # gentoo#374197
}
