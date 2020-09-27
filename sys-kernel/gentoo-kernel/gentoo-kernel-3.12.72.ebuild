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
		/lib/firmware/mts_cdma.fw
		/lib/firmware/mts_gsm.fw
		/lib/firmware/mts_edge.fw
		/lib/firmware/bnx2x/bnx2x-e1-6.2.9.0.fw
		/lib/firmware/bnx2x/bnx2x-e1h-6.2.9.0.fw
		/lib/firmware/bnx2x/bnx2x-e2-6.2.9.0.fw
		/lib/firmware/bnx2/bnx2-mips-09-6.2.1a.fw
		/lib/firmware/bnx2/bnx2-rv2p-09-6.0.17.fw
		/lib/firmware/bnx2/bnx2-rv2p-09ax-6.0.17.fw
		/lib/firmware/bnx2/bnx2-mips-06-6.2.1.fw
		/lib/firmware/bnx2/bnx2-rv2p-06-6.0.15.fw
		/lib/firmware/cxgb3/t3b_psram-1.1.0.bin
		/lib/firmware/cxgb3/t3c_psram-1.1.0.bin
		/lib/firmware/cxgb3/ael2005_opt_edc.bin
		/lib/firmware/cxgb3/ael2005_twx_edc.bin
		/lib/firmware/cxgb3/ael2020_twx_edc.bin
		/lib/firmware/matrox/g200_warp.fw
		/lib/firmware/matrox/g400_warp.fw
		/lib/firmware/r128/r128_cce.bin
		/lib/firmware/radeon/R100_cp.bin
		/lib/firmware/radeon/R200_cp.bin
		/lib/firmware/radeon/R300_cp.bin
		/lib/firmware/radeon/R420_cp.bin
		/lib/firmware/radeon/RS690_cp.bin
		/lib/firmware/radeon/RS600_cp.bin
		/lib/firmware/radeon/R520_cp.bin
		/lib/firmware/radeon/R600_pfp.bin
		/lib/firmware/radeon/R600_me.bin
		/lib/firmware/radeon/RV610_pfp.bin
		/lib/firmware/radeon/RV610_me.bin
		/lib/firmware/radeon/RV630_pfp.bin
		/lib/firmware/radeon/RV630_me.bin
		/lib/firmware/radeon/RV620_pfp.bin
		/lib/firmware/radeon/RV620_me.bin
		/lib/firmware/radeon/RV635_pfp.bin
		/lib/firmware/radeon/RV635_me.bin
		/lib/firmware/radeon/RV670_pfp.bin
		/lib/firmware/radeon/RV670_me.bin
		/lib/firmware/radeon/RS780_pfp.bin
		/lib/firmware/radeon/RS780_me.bin
		/lib/firmware/radeon/RV770_pfp.bin
		/lib/firmware/radeon/RV770_me.bin
		/lib/firmware/radeon/RV730_pfp.bin
		/lib/firmware/radeon/RV730_me.bin
		/lib/firmware/radeon/RV710_pfp.bin
		/lib/firmware/radeon/RV710_me.bin
		/lib/firmware/av7110/bootcode.bin
		/lib/firmware/e100/d101m_ucode.bin
		/lib/firmware/e100/d101s_ucode.bin
		/lib/firmware/e100/d102e_ucode.bin
		/lib/firmware/cis/LA-PCM.cis
		/lib/firmware/cis/PCMLM28.cis
		/lib/firmware/cis/DP83903.cis
		/lib/firmware/cis/NE2K.cis
		/lib/firmware/cis/tamarack.cis
		/lib/firmware/cis/PE-200.cis
		/lib/firmware/cis/PE520.cis
		/lib/firmware/cis/3CXEM556.cis
		/lib/firmware/cis/3CCFEM556.cis
		/lib/firmware/cis/MT5634ZLX.cis
		/lib/firmware/cis/RS-COM-2P.cis
		/lib/firmware/cis/COMpad2.cis
		/lib/firmware/cis/COMpad4.cis
		/lib/firmware/cis/SW_555_SER.cis
		/lib/firmware/cis/SW_7xx_SER.cis
		/lib/firmware/cis/SW_8xx_SER.cis
		/lib/firmware/advansys/mcode.bin
		/lib/firmware/advansys/38C1600.bin
		/lib/firmware/advansys/3550.bin
		/lib/firmware/advansys/38C0800.bin
		/lib/firmware/qlogic/1040.bin
		/lib/firmware/qlogic/1280.bin
		/lib/firmware/qlogic/12160.bin
		/lib/firmware/tehuti/bdx.bin
		/lib/firmware/tigon/tg3.bin
		/lib/firmware/tigon/tg3_tso.bin
		/lib/firmware/tigon/tg3_tso5.bin
		/lib/firmware/3com/typhoon.bin
		/lib/firmware/emi26/loader.fw
		/lib/firmware/emi26/firmware.fw
		/lib/firmware/emi26/bitstream.fw
		/lib/firmware/kaweth/new_code.bin
		/lib/firmware/kaweth/trigger_code.bin
		/lib/firmware/kaweth/new_code_fix.bin
		/lib/firmware/kaweth/trigger_code_fix.bin
		/lib/firmware/keyspan_pda/keyspan_pda.fw
		/lib/firmware/keyspan_pda/xircom_pgs.fw
	)
	rm "${firm_rm[@]}" || die "file collision detected"
	kernel-build_src_install
}
