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
IUSE="amd ath9k btrfs debug +efi ext4 +fat fbcondec +fuse infiniband intel nilfs2 pax pogoplug reiserfs selinux systemd thinkpad-backlight thinkpad-micled threads-4 threads-16 wireless +xfs"

REQUIRED_USE="
^^ ( amd intel )
^^ ( threads-4 threads-16 )
ath9k? ( wireless )
efi? ( fat )
"

RDEPEND="
	!sys-kernel/vanilla-kernel:${SLOT}
	!sys-kernel/vanilla-kernel-bin:${SLOT}"

pkg_pretend() {
	kernel-install_pkg_pretend
}

src_prepare() {
	local PATCHES=(
		"${FILESDIR}"/no-firmware.patch
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
		-e '/CONFIG_64BIT/s:.*:CONFIG_64BIT=y:'
		-e '/CONFIG_ACPI_CMPC/s:.*:CONFIG_ACPI_CMPC=n:'
		-e '/CONFIG_AR5523/s:.*:CONFIG_AR5523=n:'
		-e '/CONFIG_ATH5K/s:.*:CONFIG_ATH5K=n:'
		-e '/CONFIG_ATH5K_PCI/s:.*:CONFIG_ATH5K_PCI=n:'
		-e '/CONFIG_ATH6KL/s:.*:CONFIG_ATH6KL=n:'
		-e '/CONFIG_ATH9K_AHB/s:.*:CONFIG_ATH9K_AHB=n:'
		-e '/CONFIG_ATH9K_HTC/s:.*:CONFIG_ATH9K_HTC=n:'
		-e '/CONFIG_BATMAN_ADV/s:.*:CONFIG_BATMAN_ADV=n:'
		-e '/CONFIG_BLK_DEV_INITRD/s:.*:CONFIG_BLK_DEV_INITRD=n:'
		-e '/CONFIG_CARL9170/s:.*:CONFIG_CARL9170=n:'
		-e '/CONFIG_CPU_SUP_CENTAUR/s:.*:CONFIG_CPU_SUP_CENTAUR=n:'
		-e '/CONFIG_CRYPTO_PCRYPT/s:.*:CONFIG_CRYPTO_PCRYPT=n:'
		-e '/CONFIG_DRM_NOUVEAU/s:.*:CONFIG_DRM_NOUVEAU=n:'
		-e '/CONFIG_F2FS_FS/s:.*:CONFIG_F2FS_FS=n:'
		-e '/CONFIG_GFS2_FS/s:.*:CONFIG_GFS2_FS=n:'
		-e '/CONFIG_I8K/s:.*:CONFIG_I8K=n:'
		-e '/CONFIG_ISCSI_IBFT/s:.*:CONFIG_ISCSI_IBFT=n:'
		-e '/CONFIG_IXP4XX_NPE/s:.*:CONFIG_IXP4XX_NPE=n:'
		-e '/CONFIG_IXP4XX_QMGR/s:.*:CONFIG_IXP4XX_QMGR=n:'
		-e '/CONFIG_JFS_FS/s:.*:CONFIG_JFS_FS=n:'
		-e '/CONFIG_MACINTOSH_DRIVERS/s:.*:CONFIG_MACINTOSH_DRIVERS=n:'
		-e '/CONFIG_MICROCODE/s:.*:CONFIG_MICROCODE=y:'
		-e '/CONFIG_NET_VENDOR_STMICRO/s:.*:CONFIG_NET_VENDOR_STMICRO=n:'
		-e '/CONFIG_NET_VENDOR_XILINX/s:.*:CONFIG_NET_VENDOR_XILINX=n:'
		-e '/CONFIG_NILFS2_FS/s:.*:CONFIG_NILFS2_FS=n:'
		-e '/CONFIG_NTFS_FS/s:.*:CONFIG_NTFS_FS=n:'
		-e '/CONFIG_OCFS2_FS/s:.*:CONFIG_OCFS2_FS=n:'
		-e '/CONFIG_PCMCIA_FDOMAIN/s:.*:CONFIG_PCMCIA_FDOMAIN=n:'
		-e '/CONFIG_PCMCIA_RAYCS/s:.*:CONFIG_PCMCIA_RAYCS=n:'
		-e '/CONFIG_REISERFS_FS/s:.*:CONFIG_REISERFS_FS=n:'
		-e '/CONFIG_SCHED_MC/s:.*:CONFIG_SCHED_MC=n:'
		-e '/CONFIG_VIDEO_V4L2_SUBDEV_API/s:.*:CONFIG_VIDEO_V4L2_SUBDEV_API=n:'
		-e '/CONFIG_WIL6210/s:.*:CONFIG_WIL6210=n:'
	)
	use amd || config_tweaks+=(
		-e '/CONFIG_CPU_SUP_AMD/s:.*:CONFIG_CPU_SUP_AMD=n:'
		-e '/CONFIG_MICROCODE_AMD/s:.*:CONFIG_MICROCODE_AMD=n:'
	)
	if use ath9k; then
		config_tweaks+=(
			-e '/CONFIG_ATH_CARDS/s:.*:CONFIG_ATH_CARDS=y:'
			-e '/CONFIG_ATH9K/s:.*:CONFIG_ATH9K=y:'
			-e '/CONFIG_CFG80211/s:.*:CONFIG_CFG80211=y:'
			-e '/CONFIG_MAC80211/s:.*:CONFIG_MAC80211=y:'
		)
	else
		config_tweaks+=(
			-e '/CONFIG_ATH_CARDS/s:.*:CONFIG_ATH_CARDS=n:'
			-e '/CONFIG_ATH9K/s:.*:CONFIG_ATH9K=n:'
			-e '/CONFIG_CFG80211/s:.*:CONFIG_CFG80211=n:'
			-e '/CONFIG_MAC80211/s:.*:CONFIG_MAC80211=n:'
		)
	fi
	if use btrfs; then
		config_tweaks+=(
			-e '/CONFIG_BTRFS_FS/s:.*:CONFIG_BTRFS_FS=y:'
		)
	else
		config_tweaks+=(
			-e '/CONFIG_BTRFS_FS/s:.*:CONFIG_BTRFS_FS=n:'
		)
	fi
	if use debug; then
		config_tweaks+=(
			-e '/CONFIG_DEBUG_INFO/s:.*:CONFIG_DEBUG_INFO=y:'
		)
	else
		config_tweaks+=(
			-e '/CONFIG_KALLSYMS/s:.*:CONFIG_KALLSYMS=y:'
		)
	fi
	if use ext4; then
		config_tweaks+=(
			-e '/CONFIG_EXT4_FS/s:.*:CONFIG_EXT4_FS=y:'
		)
	else
		config_tweaks+=(
			-e '/CONFIG_EXT4_FS/s:.*:CONFIG_EXT4_FS=n:'
		)
	fi
	if use fat; then
		config_tweaks+=(
			-e '/CONFIG_VFAT_FS/s:.*:CONFIG_VFAT_FS=y:'
			-e '/CONFIG_MSDOS_FS/s:.*:CONFIG_MSDOS_FS=y:'
		)
	else
		config_tweaks+=(
			-e '/CONFIG_VFAT_FS/s:.*:CONFIG_VFAT_FS=n:'
			-e '/CONFIG_MSDOS_FS/s:.*:CONFIG_MSDOS_FS=n:'
		)
	fi
	if use fuse; then
		config_tweaks+=(
			-e '/CONFIG_FUSE_FS/s:.*:CONFIG_FUSE_FS=y:'
		)
	else
		config_tweaks+=(
			-e '/CONFIG_FUSE_FS/s:.*:CONFIG_FUSE_FS=n:'
		)
	fi
	use intel || config_tweaks+=(
		-e '/CONFIG_CPU_SUP_INTEL/s:.*:CONFIG_CPU_SUP_INTEL=n:'
		-e '/CONFIG_MICROCODE_INTEL/s:.*:CONFIG_MICROCODE_INTEL=n:'
	)
	use threads-4 || config_tweaks+=(
		-e '/CONFIG_NR_CPUS/s:.*:CONFIG_NR_CPUS="4":'
	)
	use threads-16 || config_tweaks+=(
		-e '/CONFIG_NR_CPUS/s:.*:CONFIG_NR_CPUS="16":'
	)
	if use wireless; then
		config_tweaks+=(
			-e '/CONFIG_RFKILL/s:.*:CONFIG_RFKILL=y:'
		)
	else
		config_tweaks+=(
			-e '/CONFIG_RFKILL/s:.*:CONFIG_RFKILL=n:'
			-e '/CONFIG_WLAN/s:.*:CONFIG_WLAN=n:'
		)
	fi
	if use xfs; then
		config_tweaks+=(
			-e '/CONFIG_XFS_FS/s:.*:CONFIG_XFS_FS=y:'
		)
	else
		config_tweaks+=(
			-e '/CONFIG_XFS_FS/s:.*:CONFIG_XFS_FS=n:'
		)
	fi
	sed -i "${config_tweaks[@]}" .config || die
	if use systemd; then
		echo 'CONFIG_GENTOO_LINUX_INIT_SCRIPT=n' >> .config
		echo 'CONFIG_GENTOO_LINUX_INIT_SYSTEMD=y' >> .config
	fi
}