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

src_install() {
	local firm_rm=(
		mts_cdma.fw
		mts_gsm.fw
		mts_edge.fw
		bnx2x/bnx2x-e1-6.2.9.0.fw
		bnx2x/bnx2x-e1h-6.2.9.0.fw
		bnx2x/bnx2x-e2-6.2.9.0.fw
		bnx2/bnx2-mips-09-6.2.1a.fw
		bnx2/bnx2-rv2p-09-6.0.17.fw
		bnx2/bnx2-rv2p-09ax-6.0.17.fw
		bnx2/bnx2-mips-06-6.2.1.fw
		bnx2/bnx2-rv2p-06-6.0.15.fw
		cxgb3/t3b_psram-1.1.0.bin
		cxgb3/t3c_psram-1.1.0.bin
		cxgb3/ael2005_opt_edc.bin
		cxgb3/ael2005_twx_edc.bin
		cxgb3/ael2020_twx_edc.bin
		matrox/g200_warp.fw
		matrox/g400_warp.fw
		r128/r128_cce.bin
		radeon/R100_cp.bin
		radeon/R200_cp.bin
		radeon/R300_cp.bin
		radeon/R420_cp.bin
		radeon/RS690_cp.bin
		radeon/RS600_cp.bin
		radeon/R520_cp.bin
		radeon/R600_pfp.bin
		radeon/R600_me.bin
		radeon/RV610_pfp.bin
		radeon/RV610_me.bin
		radeon/RV630_pfp.bin
		radeon/RV630_me.bin
		radeon/RV620_pfp.bin
		radeon/RV620_me.bin
		radeon/RV635_pfp.bin
		radeon/RV635_me.bin
		radeon/RV670_pfp.bin
		radeon/RV670_me.bin
		radeon/RS780_pfp.bin
		radeon/RS780_me.bin
		radeon/RV770_pfp.bin
		radeon/RV770_me.bin
		radeon/RV730_pfp.bin
		radeon/RV730_me.bin
		radeon/RV710_pfp.bin
		radeon/RV710_me.bin
		av7110/bootcode.bin
		e100/d101m_ucode.bin
		e100/d101s_ucode.bin
		e100/d102e_ucode.bin
		cis/LA-PCM.cis
		cis/PCMLM28.cis
		cis/DP83903.cis
		cis/NE2K.cis
		cis/tamarack.cis
		cis/PE-200.cis
		cis/PE520.cis
		cis/3CXEM556.cis
		cis/3CCFEM556.cis
		cis/MT5634ZLX.cis
		cis/RS-COM-2P.cis
		cis/COMpad2.cis
		cis/COMpad4.cis
		cis/SW_555_SER.cis
		cis/SW_7xx_SER.cis
		cis/SW_8xx_SER.cis
		advansys/mcode.bin
		advansys/38C1600.bin
		advansys/3550.bin
		advansys/38C0800.bin
		qlogic/1040.bin
		qlogic/1280.bin
		qlogic/12160.bin
		tehuti/bdx.bin
		tigon/tg3.bin
		tigon/tg3_tso.bin
		tigon/tg3_tso5.bin
		3com/typhoon.bin
		emi26/loader.fw
		emi26/firmware.fw
		emi26/bitstream.fw
		kaweth/new_code.bin
		kaweth/trigger_code.bin
		kaweth/new_code_fix.bin
		kaweth/trigger_code_fix.bin
		keyspan_pda/keyspan_pda.fw
		keyspan_pda/xircom_pgs.fw
	)
	rm -r /lib/firmware/"${firm_rm[@]}" || die "file collision detected"
	kernel-build_src_install
}
