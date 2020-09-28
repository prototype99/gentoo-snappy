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
	kernel-build_pkg_postinst
	local firmdir="${D}/lib/firmware/"
	local firmrm=(
		"${firmdir}"mts_cdma.fw
		"${firmdir}"mts_gsm.fw
		"${firmdir}"mts_edge.fw
		"${firmdir}"bnx2x/bnx2x-e1-6.2.9.0.fw
		"${firmdir}"bnx2x/bnx2x-e1h-6.2.9.0.fw
		"${firmdir}"bnx2x/bnx2x-e2-6.2.9.0.fw
		"${firmdir}"bnx2/bnx2-mips-09-6.2.1a.fw
		"${firmdir}"bnx2/bnx2-rv2p-09-6.0.17.fw
		"${firmdir}"bnx2/bnx2-rv2p-09ax-6.0.17.fw
		"${firmdir}"bnx2/bnx2-mips-06-6.2.1.fw
		"${firmdir}"bnx2/bnx2-rv2p-06-6.0.15.fw
		"${firmdir}"cxgb3/t3b_psram-1.1.0.bin
		"${firmdir}"cxgb3/t3c_psram-1.1.0.bin
		"${firmdir}"cxgb3/ael2005_opt_edc.bin
		"${firmdir}"cxgb3/ael2005_twx_edc.bin
		"${firmdir}"cxgb3/ael2020_twx_edc.bin
		"${firmdir}"matrox/g200_warp.fw
		"${firmdir}"matrox/g400_warp.fw
		"${firmdir}"r128/r128_cce.bin
		"${firmdir}"radeon/R100_cp.bin
		"${firmdir}"radeon/R200_cp.bin
		"${firmdir}"radeon/R300_cp.bin
		"${firmdir}"radeon/R420_cp.bin
		"${firmdir}"radeon/RS690_cp.bin
		"${firmdir}"radeon/RS600_cp.bin
		"${firmdir}"radeon/R520_cp.bin
		"${firmdir}"radeon/R600_pfp.bin
		"${firmdir}"radeon/R600_me.bin
		"${firmdir}"radeon/RV610_pfp.bin
		"${firmdir}"radeon/RV610_me.bin
		"${firmdir}"radeon/RV630_pfp.bin
		"${firmdir}"radeon/RV630_me.bin
		"${firmdir}"radeon/RV620_pfp.bin
		"${firmdir}"radeon/RV620_me.bin
		"${firmdir}"radeon/RV635_pfp.bin
		"${firmdir}"radeon/RV635_me.bin
		"${firmdir}"radeon/RV670_pfp.bin
		"${firmdir}"radeon/RV670_me.bin
		"${firmdir}"radeon/RS780_pfp.bin
		"${firmdir}"radeon/RS780_me.bin
		"${firmdir}"radeon/RV770_pfp.bin
		"${firmdir}"radeon/RV770_me.bin
		"${firmdir}"radeon/RV730_pfp.bin
		"${firmdir}"radeon/RV730_me.bin
		"${firmdir}"radeon/RV710_pfp.bin
		"${firmdir}"radeon/RV710_me.bin
		"${firmdir}"av7110/bootcode.bin
		"${firmdir}"e100/d101m_ucode.bin
		"${firmdir}"e100/d101s_ucode.bin
		"${firmdir}"e100/d102e_ucode.bin
		"${firmdir}"cis/LA-PCM.cis
		"${firmdir}"cis/PCMLM28.cis
		"${firmdir}"cis/DP83903.cis
		"${firmdir}"cis/NE2K.cis
		"${firmdir}"cis/tamarack.cis
		"${firmdir}"cis/PE-200.cis
		"${firmdir}"cis/PE520.cis
		"${firmdir}"cis/3CXEM556.cis
		"${firmdir}"cis/3CCFEM556.cis
		"${firmdir}"cis/MT5634ZLX.cis
		"${firmdir}"cis/RS-COM-2P.cis
		"${firmdir}"cis/COMpad2.cis
		"${firmdir}"cis/COMpad4.cis
		"${firmdir}"cis/SW_555_SER.cis
		"${firmdir}"cis/SW_7xx_SER.cis
		"${firmdir}"cis/SW_8xx_SER.cis
		"${firmdir}"advansys/mcode.bin
		"${firmdir}"advansys/38C1600.bin
		"${firmdir}"advansys/3550.bin
		"${firmdir}"advansys/38C0800.bin
		"${firmdir}"qlogic/1040.bin
		"${firmdir}"qlogic/1280.bin
		"${firmdir}"qlogic/12160.bin
		"${firmdir}"tehuti/bdx.bin
		"${firmdir}"tigon/tg3.bin
		"${firmdir}"tigon/tg3_tso.bin
		"${firmdir}"tigon/tg3_tso5.bin
		"${firmdir}"3com/typhoon.bin
		"${firmdir}"emi26/loader.fw
		"${firmdir}"emi26/firmware.fw
		"${firmdir}"emi26/bitstream.fw
		"${firmdir}"kaweth/new_code.bin
		"${firmdir}"kaweth/trigger_code.bin
		"${firmdir}"kaweth/new_code_fix.bin
		"${firmdir}"kaweth/trigger_code_fix.bin
		"${firmdir}"keyspan_pda/keyspan_pda.fw
		"${firmdir}"keyspan_pda/xircom_pgs.fw
	)
	rm "${firmrm[@]}" || die "file collision detected"
}
