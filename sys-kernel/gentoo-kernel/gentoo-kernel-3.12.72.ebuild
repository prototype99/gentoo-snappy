# Copyright 2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit kernel-build

MY_P=linux-${PV}
#i know.... i know..... the versioning is slightly wrong
GENPATCHES_P=https://dev.gentoo.org/~mpagano/genpatches/tarballs/genpatches-3.12-71
CONFIG_VER=linux-3.10.45-arch1.amd64.config
CONFIG_HASH=da3f71839fe67a897cd61c03f1347059a2079e69

DESCRIPTION="Linux kernel built with Gentoo patches"
HOMEPAGE="https://www.kernel.org/"
SRC_URI+=" https://cdn.kernel.org/pub/linux/kernel/v$(ver_cut 1).x/${MY_P}.tar.xz
	${GENPATCHES_P}.base.tar.xz
	${GENPATCHES_P}.extras.tar.xz
	https://git.archlinux.org/svntogit/packages.git/plain/trunk/config?h=packages/linux-lts&id=${CONFIG_HASH}
		-> ${CONFIG_VER}"
S=${WORKDIR}/${MY_P}

LICENSE="GPL-2"
KEYWORDS="amd64"
IUSE="+deadline debug fbcondec infiniband pax pogoplug selinux systemd thinkpad-backlight thinkpad-micled"

RDEPEND="
	!sys-kernel/vanilla-kernel:${SLOT}
	!sys-kernel/vanilla-kernel-bin:${SLOT}"

pkg_pretend() {
	kernel-install_pkg_pretend
}

src_prepare() {
	local PATCHES=(
		"${WORKDIR}"/2900_dev-root-proc-mount-fix.patch
		"${WORKDIR}"/4567_distro-Gentoo-Kconfig.patch
	)
	if use fbcondec; then
		PATCHES+=(
			"${WORKDIR}"/4200_fbcondecor-0.9.6.patch
		)
	fi
	if use infiniband; then
		PATCHES+=(
			"${WORKDIR}"/2400_kcopy-patch-for-infiniband-driver.patch
		)
	fi
	if use pax; then
		PATCHES+=(
			"${WORKDIR}"/1500_XATTR_USER_PREFIX.patch
		)
	fi
	if use pogoplug; then
		PATCHES+=(
			"${WORKDIR}"/4500_support-for-pogoplug-e02.patch
		)
	fi
	if use selinux; then
		PATCHES+=(
			"${WORKDIR}"/1500_selinux-add-SOCK_DIAG_BY_FAMILY-to-the-list-of-netli.patch
		)
	fi
	if use thinkpad-backlight; then
		PATCHES+=(
			"${WORKDIR}"/2700_ThinkPad-30-brightness-control-fix.patch
		)
	fi
	if use thinkpad-micled; then
		PATCHES+=(
			"${WORKDIR}"/1700_enable-thinkpad-micled.patch
		)
	fi
	default

	# prepare the default config
	cp "${DISTDIR}/${CONFIG_VER}" .config || die

	local config_tweaks=(
		# shove arch under the carpet!
		-e 's:^CONFIG_DEFAULT_HOSTNAME=:&"gentoo":'
	)
	#use deadline && config_tweaks+=(
	#	-e '/CONFIG_DEBUG_INFO/s:.*:CONFIG_DEBUG_INFO=y:'
	#)
	use debug && config_tweaks+=(
		-e '/CONFIG_DEBUG_INFO/s:.*:CONFIG_DEBUG_INFO=y:'
	)
	sed -i "${config_tweaks[@]}" .config || die
	if use systemd; then
		echo '/$/i CONFIG_GENTOO_LINUX_INIT_SCRIPT=n' >> .config
		echo '/$/i CONFIG_GENTOO_LINUX_INIT_SYSTEMD=y' >> .config
	fi
}

pkg_postinst() {
	INSTALL_FW_PATH="${WORKDIR}/build/trash"
	mkdir "${INSTALL_FW_PATH}"
	kernel-build_pkg_postinst
}