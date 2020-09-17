# Copyright 1999-2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=6

DESCRIPTION="Virtual for Linux kernel sources"
SLOT="${PV}"
KEYWORDS="~alpha amd64 ~arm ~arm64 ~hppa ~ia64 ~mips ~ppc ~ppc64 ~s390 ~sh ~sparc ~x86"
IUSE="firmware gentoo-sources +pf-sources"

REQUIRED_USE="^^ ( gentoo-sources pf-sources )"

RDEPEND="
	firmware? ( sys-kernel/linux-firmware )
	|| (
		gentoo-sources? ( =sys-kernel/gentoo-sources-${PV}* )
		pf-sources? ( =sys-kernel/pf-sources-${PV}* )
		|| (
			=sys-kernel/sabayon-sources-${PV}*
			=sys-kernel/odroid-sources-${PV}*
			=sys-kernel/e-sources-${PV}*
			=sys-kernel/pentoo-sources-${PV}*
			=sys-kernel/backbone-sources-${PV}*
			=sys-kernel/calculate-sources-${PV}*
			=sys-kernel/bliss-kernel-${PV}*
			=sys-kernel/vanilla-sources-${PV}*
			=sys-kernel/ck-sources-${PV}*
			=sys-kernel/git-sources-${PV}*
			=sys-kernel/hardened-sources-${PV}*
			=sys-kernel/minipli-sources-${PV}*
			=sys-kernel/lh-sources-${PV}*
			=sys-kernel/mips-sources-${PV}*
			=sys-kernel/chromeos-sources-${PV}*
			=sys-kernel/rt-sources-${PV}*
			=sys-kernel/vserver-sources-${PV}*
			=sys-kernel/xbox-sources-${PV}*
			=sys-kernel/zen-sources-${PV}*
			=sys-kernel/aufs-sources-${PV}*
			=sys-kernel/raspberrypi-sources-${PV}*
			=sys-kernel/reiser4-sources-${PV}*
			=sys-kernel/adafruit-raspberrypi-sources-${PV}*
			=sys-kernel/drm-raspberrypi-sources-${PV}*
			=sys-kernel/nouveau-sources-${PV}*
			=sys-kernel/bone-sources-${PV}*
		)
	)"