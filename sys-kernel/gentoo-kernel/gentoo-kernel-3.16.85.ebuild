# Copyright 2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit kernel-build

MY_P=linux-${PV}
#i know.... i know..... the versioning is slightly wrong
GENPATCHES_P=https://dev.gentoo.org/~mpagano/genpatches/tarballs/genpatches-3.16-9
CONFIG_VER=linux-3.14.48-arch1.amd64.config
CONFIG_HASH=4a12839b0cf7c3cc5d90c04af3f0c4650f78df33

DESCRIPTION="Linux kernel built with Gentoo patches"
HOMEPAGE="https://www.kernel.org/"
SRC_URI+="https://cdn.kernel.org/pub/linux/kernel/v3.x/${MY_P}.tar.xz
	${GENPATCHES_P}.base.tar.xz
	${GENPATCHES_P}.extras.tar.xz
	https://git.archlinux.org/svntogit/packages.git/plain/trunk/config?h=packages/linux-lts&id=${CONFIG_HASH}
		-> ${CONFIG_VER}"
S=${WORKDIR}/${MY_P}

LICENSE="GPL-2"
KEYWORDS="amd64"
IUSE="amd ath9k btrfs debug +efi ext4 +fat fbcondec +fuse infiniband intel pax pogoplug selinux systemd thinkpad-backlight thinkpad-micled threads-4 threads-16 wireless +xfs"

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
		"${FILESDIR}/${PV}"no-firmware.patch
		"${WORKDIR}"/2900_dev-root-proc-mount-fix.patch
		"${WORKDIR}"/4567_distro-Gentoo-Kconfig.patch
	)
	if gcc-major-version > 6; then
		PATCHES+=(
			"${FILESDIR}"/3.12gcc7.patch
		)
		if gcc-major-version > 7; then
			PATCHES+=(
				"${FILESDIR}/${PV}"log2.h-gcc8.patch
				"${FILESDIR}/${PV}"exec.c-sched.h-gcc8.patch
			)
			if gcc-major-version > 8; then
				PATCHES+=(
					"${FILESDIR}"/gcc9.patch
				)
				if gcc-major-version < 10; then
					gcc-minor-version > 0 && PATCHES+=(
						"${FILESDIR}"/3.12gcc9.1.patch
					)
				else
					PATCHES+=(
						"${FILESDIR}"/3.12gcc9.1.patch
					)
				fi
			fi
		fi
	fi
	if use fbcondec; then
		PATCHES+=(
			"${WORKDIR}"/4200_fbcondecor-3.15.patch
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
		-e '/CONFIG_9P_FS/s:.*:CONFIG_9P_FS=n:'
		-e '/CONFIG_ACPI_CMPC/s:.*:CONFIG_ACPI_CMPC=n:'
		-e '/CONFIG_AFS_FS/s:.*:CONFIG_AFS_FS=n:'
		-e '/CONFIG_AGP/s:.*:CONFIG_AGP=y:'
		-e '/CONFIG_AGP_AMD64/s:.*:CONFIG_AGP_AMD64=n:'
		-e '/CONFIG_AGP_SIS/s:.*:CONFIG_AGP_SIS=n:'
		-e '/CONFIG_AGP_VIA/s:.*:CONFIG_AGP_VIA=n:'
		-e '/CONFIG_AIX_PARTITION/s:.*:CONFIG_AIX_PARTITION=n:'
		-e '/CONFIG_ALIX/s:.*:CONFIG_ALIX=n:'
		-e '/CONFIG_AR5523/s:.*:CONFIG_AR5523=n:'
		-e '/CONFIG_ATA/s:.*:CONFIG_ATA=y:'
		-e '/CONFIG_ATH5K/s:.*:CONFIG_ATH5K=n:'
		-e '/CONFIG_ATH5K_PCI/s:.*:CONFIG_ATH5K_PCI=n:'
		-e '/CONFIG_ATH6KL/s:.*:CONFIG_ATH6KL=n:'
		-e '/CONFIG_ATH9K_AHB/s:.*:CONFIG_ATH9K_AHB=n:'
		-e '/CONFIG_ATH9K_HTC/s:.*:CONFIG_ATH9K_HTC=n:'
		-e '/CONFIG_ATH10K/s:.*:CONFIG_ATH10K=n:'
		-e '/CONFIG_BATMAN_ADV/s:.*:CONFIG_BATMAN_ADV=n:'
		-e '/CONFIG_BLK_DEV_INITRD/s:.*:CONFIG_BLK_DEV_INITRD=n:'
		-e '/CONFIG_BLK_DEV_SD/s:.*:CONFIG_BLK_DEV_SD=n:'
		-e '/CONFIG_BLK_DEV_SR/s:.*:CONFIG_BLK_DEV_SR=n:'
		-e '/CONFIG_CARL9170/s:.*:CONFIG_CARL9170=n:'
		-e '/CONFIG_CEPH_FS/s:.*:CONFIG_CEPH_FS=n:'
		-e '/CONFIG_CHR_DEV_OSST/s:.*:CONFIG_CHR_DEV_OSST=n:'
		-e '/CONFIG_CHR_DEV_SCH/s:.*:CONFIG_CHR_DEV_SCH=n:'
		-e '/CONFIG_CHR_DEV_SG/s:.*:CONFIG_CHR_DEV_SG=n:'
		-e '/CONFIG_CIFS/s:.*:CONFIG_CIFS=n:'
		-e '/CONFIG_CODA_FS/s:.*:CONFIG_CODA_FS=n:'
		-e '/CONFIG_CPU_SUP_CENTAUR/s:.*:CONFIG_CPU_SUP_CENTAUR=n:'
		-e '/CONFIG_CRYPTO_PCRYPT/s:.*:CONFIG_CRYPTO_PCRYPT=n:'
		-e '/CONFIG_DRM_AST/s:.*:CONFIG_DRM_AST=n:'
		-e '/CONFIG_DRM_CIRRUS_QEMU/s:.*:CONFIG_DRM_CIRRUS_QEMU=n:'
		-e '/CONFIG_DRM_GMA500/s:.*:CONFIG_DRM_GMA500=n:'
		-e '/CONFIG_DRM_I2C_CH7006/s:.*:CONFIG_DRM_I2C_CH7006=n:'
		-e '/CONFIG_DRM_I2C_NXP_TDA998X/s:.*:CONFIG_DRM_I2C_NXP_TDA998X=n:'
		-e '/CONFIG_DRM_I2C_SIL164/s:.*:CONFIG_DRM_I2C_SIL164=n:'
		-e '/CONFIG_DRM_MGA/s:.*:CONFIG_DRM_MGA=n:'
		-e '/CONFIG_DRM_MGAG200/s:.*:CONFIG_DRM_MGAG200=n:'
		-e '/CONFIG_DRM_NOUVEAU/s:.*:CONFIG_DRM_NOUVEAU=n:'
		-e '/CONFIG_DRM_QXL/s:.*:CONFIG_DRM_QXL=n:'
		-e '/CONFIG_DRM_R128/s:.*:CONFIG_DRM_R128=n:'
		-e '/CONFIG_DRM_RADEON/s:.*:CONFIG_DRM_RADEON=n:'
		-e '/CONFIG_DRM_SAVAGE/s:.*:CONFIG_DRM_SAVAGE=n:'
		-e '/CONFIG_DRM_SIS/s:.*:CONFIG_DRM_SIS=n:'
		-e '/CONFIG_DRM_TDFX/s:.*:CONFIG_DRM_TDFX=n:'
		-e '/CONFIG_DRM_UDL/s:.*:CONFIG_DRM_UDL=n:'
		-e '/CONFIG_DRM_VIA/s:.*:CONFIG_DRM_VIA=n:'
		-e '/CONFIG_DRM_VMWGFX/s:.*:CONFIG_DRM_VMWGFX=n:'
		-e '/CONFIG_DNET/s:.*:CONFIG_DNET=n:'
		-e '/CONFIG_ET131X/s:.*:CONFIG_ET131X=n:'
		-e '/CONFIG_F2FS_FS/s:.*:CONFIG_F2FS_FS=n:'
		-e '/CONFIG_FEALNX/s:.*:CONFIG_FEALNX=n:'
		-e '/CONFIG_FRAMEBUFFER_CONSOLE_ROTATION/s:.*:CONFIG_FRAMEBUFFER_CONSOLE_ROTATION=n:'
		-e '/CONFIG_GFS2_FS/s:.*:CONFIG_GFS2_FS=n:'
		-e '/CONFIG_HSR/s:.*:CONFIG_HSR=n:'
		-e '/CONFIG_I8K/s:.*:CONFIG_I8K=n:'
		-e '/CONFIG_IP1000/s:.*:CONFIG_IP1000=n:'
		-e '/CONFIG_ISCSI_IBFT/s:.*:CONFIG_ISCSI_IBFT=n:'
		-e '/CONFIG_IXP4XX_NPE/s:.*:CONFIG_IXP4XX_NPE=n:'
		-e '/CONFIG_IXP4XX_QMGR/s:.*:CONFIG_IXP4XX_QMGR=n:'
		-e '/CONFIG_JFS_FS/s:.*:CONFIG_JFS_FS=n:'
		-e '/CONFIG_JME/s:.*:CONFIG_JME=n:'
		-e '/CONFIG_LOGO/s:.*:CONFIG_LOGO=y:'
		-e '/CONFIG_MACINTOSH_DRIVERS/s:.*:CONFIG_MACINTOSH_DRIVERS=n:'
		-e '/CONFIG_NCP_FS/s:.*:CONFIG_NCP_FS=n:'
		-e '/CONFIG_NET_CALXEDA_XGMAC/s:.*:CONFIG_NET_CALXEDA_XGMAC=n:'
		-e '/CONFIG_NET_PACKET_ENGINE/s:.*:CONFIG_NET_PACKET_ENGINE=n:'
		-e '/CONFIG_NET_SB1000/s:.*:CONFIG_NET_SB1000=n:'
		-e '/CONFIG_NET_VENDOR_3COM/s:.*:CONFIG_NET_VENDOR_3COM=n:'
		-e '/CONFIG_NET_VENDOR_ADAPTEC/s:.*:CONFIG_NET_VENDOR_ADAPTEC=n:'
		-e '/CONFIG_NET_VENDOR_ALTEON/s:.*:CONFIG_NET_VENDOR_ALTEON=n:'
		-e '/CONFIG_NET_VENDOR_AMD/s:.*:CONFIG_NET_VENDOR_AMD=n:'
		-e '/CONFIG_NET_VENDOR_ARC/s:.*:CONFIG_NET_VENDOR_ARC=n:'
		-e '/CONFIG_NET_VENDOR_ATHEROS/s:.*:CONFIG_NET_VENDOR_ATHEROS=n:'
		-e '/CONFIG_NET_VENDOR_BROCADE/s:.*:CONFIG_NET_VENDOR_BROCADE=n:'
		-e '/CONFIG_NET_VENDOR_CADENCE/s:.*:CONFIG_NET_VENDOR_CADENCE=n:'
		-e '/CONFIG_NET_VENDOR_CISCO/s:.*:CONFIG_NET_VENDOR_CISCO=n:'
		-e '/CONFIG_NET_VENDOR_DEC/s:.*:CONFIG_NET_VENDOR_DEC=n:'
		-e '/CONFIG_NET_VENDOR_DLINK/s:.*:CONFIG_NET_VENDOR_DLINK=n:'
		-e '/CONFIG_NET_VENDOR_EMULEX/s:.*:CONFIG_NET_VENDOR_EMULEX=n:'
		-e '/CONFIG_NET_VENDOR_ETHOC/s:.*:CONFIG_NET_VENDOR_ETHOC=n:'
		-e '/CONFIG_NET_VENDOR_EXAR/s:.*:CONFIG_NET_VENDOR_EXAR=n:'
		-e '/CONFIG_NET_VENDOR_FUJITSU/s:.*:CONFIG_NET_VENDOR_FUJITSU=n:'
		-e '/CONFIG_NET_VENDOR_HP/s:.*:CONFIG_NET_VENDOR_HP=n:'
		-e '/CONFIG_NET_VENDOR_MARVELL/s:.*:CONFIG_NET_VENDOR_MARVELL=n:'
		-e '/CONFIG_NET_VENDOR_MELLANOX/s:.*:CONFIG_NET_VENDOR_MELLANOX=n:'
		-e '/CONFIG_NET_VENDOR_MICREL/s:.*:CONFIG_NET_VENDOR_MICREL=n:'
		-e '/CONFIG_NET_VENDOR_MICROCHIP/s:.*:CONFIG_NET_VENDOR_MICROCHIP=n:'
		-e '/CONFIG_NET_VENDOR_MYRI/s:.*:CONFIG_NET_VENDOR_MYRI=n:'
		-e '/CONFIG_NET_VENDOR_NATSEMI/s:.*:CONFIG_NET_VENDOR_NATSEMI=n:'
		-e '/CONFIG_NET_VENDOR_NVIDIA/s:.*:CONFIG_NET_VENDOR_NVIDIA=n:'
		-e '/CONFIG_NET_VENDOR_OKI/s:.*:CONFIG_NET_VENDOR_OKI=n:'
		-e '/CONFIG_NET_VENDOR_QLOGIC/s:.*:CONFIG_NET_VENDOR_QLOGIC=n:'
		-e '/CONFIG_NET_VENDOR_RDC/s:.*:CONFIG_NET_VENDOR_RDC=n:'
		-e '/CONFIG_NET_VENDOR_REALTEK/s:.*:CONFIG_NET_VENDOR_REALTEK=n:'
		-e '/CONFIG_NET_VENDOR_SEEQ/s:.*:CONFIG_NET_VENDOR_SEEQ=n:'
		-e '/CONFIG_NET_VENDOR_SILAN/s:.*:CONFIG_NET_VENDOR_SILAN=n:'
		-e '/CONFIG_NET_VENDOR_SIS/s:.*:CONFIG_NET_VENDOR_SIS=n:'
		-e '/CONFIG_NET_VENDOR_SMSC/s:.*:CONFIG_NET_VENDOR_SMSC=n:'
		-e '/CONFIG_NET_VENDOR_STMICRO/s:.*:CONFIG_NET_VENDOR_STMICRO=n:'
		-e '/CONFIG_NET_VENDOR_SUN/s:.*:CONFIG_NET_VENDOR_SUN=n:'
		-e '/CONFIG_NET_VENDOR_TEHUTI/s:.*:CONFIG_NET_VENDOR_TEHUTI=n:'
		-e '/CONFIG_NET_VENDOR_TI/s:.*:CONFIG_NET_VENDOR_TI=n:'
		-e '/CONFIG_NET_VENDOR_VIA/s:.*:CONFIG_NET_VENDOR_VIA=n:'
		-e '/CONFIG_NET_VENDOR_WIZNET/s:.*:CONFIG_NET_VENDOR_WIZNET=n:'
		-e '/CONFIG_NET_VENDOR_XILINX/s:.*:CONFIG_NET_VENDOR_XILINX=n:'
		-e '/CONFIG_NET_VENDOR_XIRCOM/s:.*:CONFIG_NET_VENDOR_XIRCOM=n:'
		-e '/CONFIG_NETWORK_FILESYSTEMS/s:.*:CONFIG_NETWORK_FILESYSTEMS=n:'
		-e '/CONFIG_NFC/s:.*:CONFIG_NFC=n:'
		-e '/CONFIG_NFS_FS/s:.*:CONFIG_NFS_FS=n:'
		-e '/CONFIG_NFSD/s:.*:CONFIG_NFSD=n:'
		-e '/CONFIG_NILFS2_FS/s:.*:CONFIG_NILFS2_FS=n:'
		-e '/CONFIG_NTFS_FS/s:.*:CONFIG_NTFS_FS=n:'
		-e '/CONFIG_OCFS2_FS/s:.*:CONFIG_OCFS2_FS=n:'
		-e '/CONFIG_OPENVSWITCH/s:.*:CONFIG_OPENVSWITCH=n:'
		-e '/CONFIG_PCMCIA_FDOMAIN/s:.*:CONFIG_PCMCIA_FDOMAIN=n:'
		-e '/CONFIG_PCMCIA_RAYCS/s:.*:CONFIG_PCMCIA_RAYCS=n:'
		-e '/CONFIG_PRISM2_USB/s:.*:CONFIG_PRISM2_USB=n:'
		-e '/CONFIG_R8187SE/s:.*:CONFIG_R8187SE=n:'
		-e '/CONFIG_R8712U/s:.*:CONFIG_R8712U=n:'
		-e '/CONFIG_RAPIDIO/s:.*:CONFIG_RAPIDIO=n:'
		-e '/CONFIG_REISERFS_FS/s:.*:CONFIG_REISERFS_FS=n:'
		-e '/CONFIG_RTL8192U/s:.*:CONFIG_RTL8192U=n:'
		-e '/CONFIG_RTLLIB/s:.*:CONFIG_RTLLIB=n:'
		-e '/CONFIG_RTS5139/s:.*:CONFIG_RTS5139=n:'
		-e '/CONFIG_SATA_AHCI/s:.*:CONFIG_SATA_AHCI=y:'
		-e '/CONFIG_SCHED_MC/s:.*:CONFIG_SCHED_MC=n:'
		-e '/CONFIG_SCSI/s:.*:CONFIG_SCSI=n:'
		-e '/CONFIG_SCSI_DH/s:.*:CONFIG_SCSI_DH=n:'
		-e '/CONFIG_SCSI_ENCLOSURE/s:.*:CONFIG_SCSI_ENCLOSURE=n:'
		-e '/CONFIG_SCSI_LOWLEVEL/s:.*:CONFIG_SCSI_LOWLEVEL=n:'
		-e '/CONFIG_SCSI_LOWLEVEL_PCMCIA/s:.*:CONFIG_SCSI_LOWLEVEL_PCMCIA=n:'
		-e '/CONFIG_SCSI_MULTI_LUN/s:.*:CONFIG_SCSI_MULTI_LUN=n:'
		-e '/CONFIG_SCSI_SCAN_ASYNC/s:.*:CONFIG_SCSI_SCAN_ASYNC=n:'
		-e '/CONFIG_SFC/s:.*:CONFIG_SFC=n:'
		-e '/CONFIG_SLICOSS/s:.*:CONFIG_SLICOSS=n:'
		-e '/CONFIG_SND/s:.*:CONFIG_SND=y:'
		-e '/CONFIG_SND_HDA_CODEC_ANALOG/s:.*:CONFIG_SND_HDA_CODEC_ANALOG=n:'
		-e '/CONFIG_SND_HDA_CODEC_CA0110/s:.*:CONFIG_SND_HDA_CODEC_CA0110=n:'
		-e '/CONFIG_SND_HDA_CODEC_CA0132/s:.*:CONFIG_SND_HDA_CODEC_CA0132=n:'
		-e '/CONFIG_SND_HDA_CODEC_CIRRUS/s:.*:CONFIG_SND_HDA_CODEC_CIRRUS=n:'
		-e '/CONFIG_SND_HDA_CODEC_CMEDIA/s:.*:CONFIG_SND_HDA_CODEC_CMEDIA=n:'
		-e '/CONFIG_SND_HDA_CODEC_CONEXANT/s:.*:CONFIG_SND_HDA_CODEC_CONEXANT=n:'
		-e '/CONFIG_SND_HDA_CODEC_HDMI/s:.*:CONFIG_SND_HDA_CODEC_HDMI=n:'
		-e '/CONFIG_SND_HDA_CODEC_REALTEK/s:.*:CONFIG_SND_HDA_CODEC_REALTEK=n:'
		-e '/CONFIG_SND_HDA_CODEC_SI3054/s:.*:CONFIG_SND_HDA_CODEC_SI3054=n:'
		-e '/CONFIG_SND_HDA_CODEC_VIA/s:.*:CONFIG_SND_HDA_CODEC_VIA=n:'
		-e '/CONFIG_SND_HDA_INTEL/s:.*:CONFIG_SND_HDA_INTEL=n:'
		-e '/CONFIG_SND_HDA_PREALLOC_SIZE/s:.*:CONFIG_SND_HDA_PREALLOC_SIZE=32768:'
		-e '/CONFIG_SOUND/s:.*:CONFIG_SOUND=y:'
		-e '/CONFIG_USB/s:.*:CONFIG_USB=y:'
		-e '/CONFIG_USB_EHCI_HCD/s:.*:CONFIG_USB_EHCI_HCD=y:'
		-e '/CONFIG_VGA_ARB_MAX_GPUS/s:.*:CONFIG_VGA_ARB_MAX_GPUS=1:'
		-e '/CONFIG_VGA_SWITCHEROO/s:.*:CONFIG_VGA_SWITCHEROO=n:'
		-e '/CONFIG_VIDEO_V4L2_SUBDEV_API/s:.*:CONFIG_VIDEO_V4L2_SUBDEV_API=n:'
		-e '/CONFIG_W35UND/s:.*:CONFIG_W35UND=n:'
		-e '/CONFIG_VT665/s:.*:CONFIG_VT6655=n:'
		-e '/CONFIG_VT665/s:.*:CONFIG_VT6656=n:'
		-e '/CONFIG_WATCHDOG/s:.*:CONFIG_WATCHDOG=n:'
		-e '/CONFIG_WIL6210/s:.*:CONFIG_WIL6210=n:'
		-e '/CONFIG_X86/s:.*:CONFIG_X86=n:'
		-e '/CONFIG_X86_16BIT/s:.*:CONFIG_X86_16BIT=n:'
		-e '/LOGO_LINUX_MONO/s:.*:LOGO_LINUX_MONO=n:'
		-e '/LOGO_LINUX_VGA16/s:.*:LOGO_LINUX_VGA16=n:'
	)
	use amd || config_tweaks+=(
		-e '/CONFIG_CPU_SUP_AMD/s:.*:CONFIG_CPU_SUP_AMD=n:'
		-e '/CONFIG_MICROCODE_AMD/s:.*:CONFIG_MICROCODE_AMD=n:'
		-e '/CONFIG_MICROCODE_AMD_EARLY/s:.*:CONFIG_MICROCODE_AMD_EARLY=n:'
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
			-e '/CONFIG_ACPI_EXTLOG/s:.*:CONFIG_ACPI_EXTLOG=y:'
		)
	else
		config_tweaks+=(
			-e '/CONFIG_KALLSYMS/s:.*:CONFIG_KALLSYMS=y:'
			-e '/CONFIG_ACPI_EXTLOG/s:.*:CONFIG_ACPI_EXTLOG=n:'
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
	if use intel; then
		config_tweaks+=(
			-e '/CONFIG_AGP_INTEL/s:.*:CONFIG_AGP_INTEL=y:'
			-e '/CONFIG_DRM/s:.*:CONFIG_DRM=y:'
			-e '/CONFIG_DRM_I915/s:.*:CONFIG_DRM_I915=y:'
			-e '/CONFIG_I2C_I801/s:.*:CONFIG_I2C_I801=y:'
		)
	else
		config_tweaks+=(
			-e '/CONFIG_AGP_INTEL/s:.*:CONFIG_AGP_INTEL=n:'
			-e '/CONFIG_CPU_SUP_INTEL/s:.*:CONFIG_CPU_SUP_INTEL=n:'
			-e '/CONFIG_DRM/s:.*:CONFIG_DRM=n:'
			-e '/CONFIG_DRM_I915/s:.*:CONFIG_DRM_I915=n:'
			-e '/CONFIG_I2C_I801/s:.*:CONFIG_I2C_I801=n:'
			-e '/CONFIG_MICROCODE_INTEL/s:.*:CONFIG_MICROCODE_INTEL=n:'
		)
	fi
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
	echo 'CONFIG_BLK_DEV_ST=n' >> .config
	if use systemd; then
		echo 'CONFIG_GENTOO_LINUX_INIT_SCRIPT=n' >> .config
		echo 'CONFIG_GENTOO_LINUX_INIT_SYSTEMD=y' >> .config
	fi
}