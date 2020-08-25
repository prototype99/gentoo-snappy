# Copyright 1999-2019 Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7
inherit linux-info systemd

DESCRIPTION="Meta package to pull in packages and scripts to help keep the world file clean"
HOMEPAGE="https://github.com/sophietheopossum/blood-of-the-chimera"
SLOT="0"
KEYWORDS="~alpha amd64 ~arm ~arm64 ~hppa ~ia64 ~mips ~ppc ~ppc64 ~s390 ~sh ~sparc ~x86"
IUSE="amd anaconda archive ath9k +bfq bmq broadcom +browser btrfs bzip2 cad +chrome +composite copy-notify debug dev discord dolphin +efi ext2 exfat +extended-glyphs f2fs +fat +filemanager firefox flash +fluxbox fslint ftp fvwm gentoo-patches gentoo-sources +gnomekeyring-admin gzip hygon img-dim img-dim-hover img-dim-hover-list img-dim-hover-tile img-dim-jpg img-dim-prop +index inkscape intel irc ivybridge java-ide kate kyber latex logisim lz4 lzma +lzo mail-client mips-emulate mod-date-list mod-date-prop mod-time-list +network-tray odt openbox openrc overlay +pantheon-files pcmanfm-qt pdf-edit parted +pf-sources php-ide +processviewer progress-icon remote-desktop save-state screenshot secondlife secure show-read show-sym show-write spreadsheet sql steam sublime sublimelinter +sudo svg-edit system-flake8 system-pylint +systemd terminal +terminal-fast test +text-editor text-editor-color-highlight text-editor-js-complete text-editor-js-lint text-editor-php-lint text-editor-py-complete text-editor-py-lint threads-4 threads-16 threads-512 +thumbnail-jpg thumbnail-odp +thumbnail-odt +thumbnail-png thumbnail-pptx +thumbnail-svg +uefi view-font view-pdf view-pdf-accurate view-png xeon +xfs xz yandex-disk zhaoxin"
S="${WORKDIR}"

REQUIRED_USE="
^^ ( amd hygon intel zhaoxin )
^^ ( bfq bmq kyber )
|| ( bzip2 gzip lz4 lzma lzo xz )
^^ ( fluxbox fvwm openbox )
^^ ( gentoo-sources pf-sources )
^^ ( terminal-fast terminal )
^^ ( threads-4 threads-16 threads-512 )
anaconda? ( sublime )
bmq? ( pf-sources )
browser? ( || ( firefox chrome ) )
copy-notify? ( dolphin )
efi? ( fat )
filemanager? ( ^^ ( pantheon-files pcmanfm-qt dolphin ) )
gentoo-patches? ( ^^ ( openrc systemd ) )
gentoo-sources? ( gentoo-patches )
img-dim? ( ^^ ( img-dim-hover img-dim-prop ) )
img-dim-hover? ( || ( img-dim-hover-list img-dim-hover-tile ) )
img-dim-hover-list? ( pantheon-files )
img-dim-hover-tile? ( pantheon-files )
img-dim-jpg? ( pantheon-files )
img-dim-prop? ( pantheon-files )
ivybridge? ( intel threads-4 )
kate? ( text-editor )
mod-date-list? ( || ( pantheon-files pcmanfm-qt ) )
mod-date-prop? ( || ( pantheon-files pcmanfm-qt ) )
mod-time-list? ( pcmanfm-qt )
view-pdf? ( || ( browser inkscape view-pdf-accurate ) )
view-png? ( || ( browser inkscape view-pdf-accurate ) )
pf-sources? ( gentoo-patches )
save-state? ( pantheon-files )
show-read? ( pantheon-files )
show-sym? ( pantheon-files )
show-write? ( pantheon-files )
sublime? ( text-editor )
sublimelinter? ( sublime )
svg-edit? ( inkscape )
system-flake8? ( sublimelinter )
system-pylint? ( sublimelinter )
text-editor ( || ( kate sublime ) )
text-editor-color-highlight? ( sublime )
text-editor-js-lint? ( sublimelinter )
text-editor-php-lint? ( sublimelinter )
text-editor-py-complete? ( anaconda )
text-editor-py-lint? ( || ( ( system-flake8 system-pylint ) anaconda ) )
thumbnail-jpg? ( || ( pantheon-files pcmanfm-qt ) )
thumbnail-odp? ( || ( pantheon-files pcmanfm-qt ) )
thumbnail-odt? ( || ( pantheon-files pcmanfm-qt ) )
thumbnail-png? ( || ( pantheon-files pcmanfm-qt ) )
thumbnail-pptx? ( || ( pantheon-files pcmanfm-qt ) )
thumbnail-svg? ( || ( pantheon-files pcmanfm-qt ) )
xeon? ( intel )
"

RDEPEND="
	archive? ( app-arch/xarchiver )
	btrfs? ( sys-fs/btrfs-progs )
	cad? ( media-gfx/solvespace )
	chrome? ( || ( >=www-client/chromium-78 www-client/google-chrome-beta www-client/google-chrome-unstable >=www-client/google-chrome-78 ) )
	composite? ( x11-misc/picom )
	dev? ( app-portage/repoman mail-mta/msmtp media-libs/fontconfig-ultimate dev-python/beautifulsoup )
	discord? ( net-im/discord-bin )
	dolphin? ( kde-apps/dolphin )
	extended-glyphs? ( media-fonts/noto )
	fat? ( sys-fs/dosfstools )
	firefox? ( || ( www-client/firefox www-client/firefox-bin ) flash? ( www-plugins/freshplayerplugin ) )
	fluxbox? ( x11-wm/fluxbox )
	fvwm? ( x11-wm/fvwm )
	font_family_arial? ( media-fonts/liberation-fonts )
	font_family_courier? ( media-fonts/liberation-fonts )
	font_family_helvetica? ( media-fonts/liberation-fonts )
	font_family_times_new_roman? ( media-fonts/liberation-fonts )
	font_set_basic_latin? ( media-fonts/liberation-fonts )
	font_set_latin_extended_a? ( media-fonts/liberation-fonts )
	font_style_mono? ( media-fonts/liberation-fonts )
	font_style_sans? ( media-fonts/liberation-fonts )
	font_style_serif? ( media-fonts/liberation-fonts )
	fslint? ( app-misc/fslint )
	ftp? ( net-ftp/filezilla )
	gnomekeyring-admin? ( app-crypt/seahorse )
	index? ( sys-apps/mlocate )
	inkscape? ( media-gfx/inkscape )
	irc? ( net-irc/kvirc )
	java-ide? ( >=dev-util/eclipse-sdk-bin-4.13.0 )
	kate? ( kde-plasma/plasma-meta[text-editor] )
	latex? ( app-office/lyx dev-tex/tex4ht )
	logisim? ( sci-electronics/logisim-evolution-holy-cross )
	lzo? ( app-arch/lzop )
	mail-client? ( mail-client/mailspring )
	mips-emulate? ( app-emulation/mars-mips )
	network-tray? ( gnome-extra/nm-applet )
	odt? ( || ( app-office/libreoffice app-office/libreoffice-bin ) )
	!openbox? ( lxqt-base/lxqt-meta[minimal] )
	overlay? ( app-portage/layman )
	pantheon-files? (
		pantheon-base/pantheon-files[mod-date-prop?,img-dim-hover-list?,img-dim-jpg?,progress-icon?,thumbnail-jpg?]
	)
	parted? ( sys-block/gparted )
	!pcmanfm-qt? ( lxqt-base/lxqt-meta[-filemanager] )
	php-ide? ( dev-php/phpstorm )
	processviewer? ( kde-plasma/plasma-meta[processviewer] )
	remote-desktop? ( net-misc/anydesk )
	screenshot? ( media-gfx/flameshot )
	secondlife? ( games-simulation/firestorm-bin )
	spreadsheet? ( app-office/gnumeric )
	sql? ( dev-db/mariadb )
	steam? ( games-util/steam-launcher )
	sublime? ( app-editors/sublime-text )
	sudo? ( app-admin/sudo )
	system-flake8? ( dev-python/flake8 )
	system-pylint? ( >=dev-python/pylint-1.0 )
	terminal? ( lxqt-base/lxqt-meta[terminal] )
	terminal-fast? ( x11-terms/kitty )
	text-editor-js-lint? ( net-libs/nodejs[npm] )
	text-editor-php-lint? ( dev-lang/php )
	view-font? ( media-gfx/fontforge[X] )
	view-pdf-accurate? ( app-text/mupdf )
	xfs? ( sys-fs/xfsprogs )
	yandex-disk? ( net-misc/yandex-disk )
"

pkg_setup() {
	linux-info_pkg_setup
	CONFIG_CHECK="CC_OPTIMIZE_FOR_PERFORMANCE KEYS_REQUEST_CACHE LEGACY_VSYSCALL_XONLY MAX_SMP MICROCODE MSDOS_PARTITION NVMEM_SYSFS PROCESSOR_SELECT SHUFFLE_PAGE_ALLOCATOR !ACPI_CMPC !ACPI_HMAT !ACRN_GUEST !AX88796B_PHY !BATMAN_ADV !BLK_DEV_INITRD !BT_HCIBTUSB_MTK !BT_MTKSDIO !CFG80211_DEFAULT_PS !CFG80211_CRDA_SUPPORT !CHARGER_MANAGER !COMMON_CLK_SI5341 !COUNTER !CPU_SUP_CENTAUR !CRYPTO_DEV_ATMEL_ECC CRYPTO_DEV_ATMEL_SHA204A !CRYPTO_ECRDSA !CRYPTO_XXHASH !DEBUG_MISC !DEBUG_PLIST !DM_DUST !DRM_NOUVEAU !DW_EDMA !DW_EDMA_PCIE !FIELDBUS_DEV !FW_LOADER_COMPRESS !GCC_PLUGIN_CYC_COMPLEXITY !GCC_PLUGIN_LATENT_ENTROPY !GCC_PLUGIN_RANDSTRUCT !GCC_PLUGIN_STACKLEAK !HEADERS_INSTALL !HID_MACALLY !HID_U2FZERO !HMM_MIRROR !I2C_AMD_MP2 !I8K !IKHEADERS !INPUT_REGULATOR_HAPTIC !INTEL_ISH_HID !IPMB_DEVICE_INTERFACE !ISCSI_IBFT !IXP4XX_NPE !IXP4XX_QMGR !KEYBOARD_QT1050 !KPC2000 !LEDS_LM3532 !LEDS_REGULATOR !LEDS_TI_LMU_COMMON !LOCK_EVENT_COUNTS !MACINTOSH_DRIVERS !NET_ACT_CT !NET_ACT_CTINFO !NET_ACT_MPLS !NET_DSA_TAG_SJA1105 !NET_VENDOR_GOOGLE !NET_VENDOR_STMICRO !NET_VENDOR_XILINX !NF_CONNTRACK_BRIDGE !NFT_BRIDGE_META !NFT_SYNPROXY !NTFS_FS !NULL_TTY !NXP_TJA11XX_PHY !PACKING !PCMCIA_FDOMAIN !REGULATOR_88PG86X !REGULATOR_88PM800 !REGULATOR_ACT8865 !REGULATOR_AD5398 !REGULATOR_ANATOP !REGULATOR_AXP20X !REGULATOR_BCM590XX !REGULATOR_DA9062 !REGULATOR_DA9063 !REGULATOR_DA9210 !REGULATOR_DA9211 !REGULATOR_DEBUG !REGULATOR_FAN53555 !REGULATOR_FIXED_VOLTAGE !REGULATOR_ISL9305 !REGULATOR_ISL6271A !REGULATOR_LP3971 !REGULATOR_LP3972 !REGULATOR_LP872X !REGULATOR_LP8755 !REGULATOR_LTC3589 !REGULATOR_LTC3676 !REGULATOR_MAX14577 !REGULATOR_MAX1586 !REGULATOR_MAX8649 !REGULATOR_MAX8660 !REGULATOR_MAX8907 !REGULATOR_MAX8952 !REGULATOR_MAX77693 !REGULATOR_MT6311 !REGULATOR_PFUZE100 !REGULATOR_PV88060 !REGULATOR_PV88080 !REGULATOR_PV88090 !REGULATOR_QCOM_SPMI !REGULATOR_RT5033 !REGULATOR_TPS51632 !REGULATOR_TPS62360 !REGULATOR_TPS65023 !REGULATOR_TPS6507X !REGULATOR_TPS65086 !REGULATOR_TPS65912 !REGULATOR_USERSPACE_CONSUMER !REGULATOR_VIRTUAL_CONSUMER !SCHED_MC !SCSI_FDOMAIN_PCI !SENSORS_IR38064 !SENSORS_ISL68137 !SENSORS_LTC2978_REGULATOR !TEST_STRSCPY !TOUCHSCREEN_IQS5XX !TYPEC_DP_ALTMODE !UNICODE !USELIB !VIDEO_V4L2_SUBDEV_API !XILINX_SDFEC !ZONE_DMA"
	if use gentoo-patches; then
		CONFIG_CHECK="GENTOO_LINUX GENTOO_LINUX_PORTAGE"
		if use openrc; then
			CONFIG_CHECK="GENTOO_LINUX_INIT_SCRIPT"
		else
			CONFIG_CHECK="!GENTOO_LINUX_INIT_SCRIPT"
		fi
		if use systemd; then
			CONFIG_CHECK="GENTOO_LINUX_INIT_SYSTEMD"
		else
			CONFIG_CHECK="!GENTOO_LINUX_INIT_SYSTEMD"
		fi
	fi
	if use amd; then
		CONFIG_CHECK="CPU_SUP_AMD MICROCODE_AMD"
	else
		CONFIG_CHECK="!CPU_SUP_AMD"
	fi
	if use ath9k; then
		CONFIG_CHECK="ATH9K ATH9K_DYNACK ATH9K_HWRNG WLAN_VENDOR_ATH"
	else
		CONFIG_CHECK="!WLAN_VENDOR_ATH"
	fi
	if use bfq; then
		CONFIG_CHECK="IOSCHED_BFQ"
		use debug && CONFIG_CHECK="BFQ_CGROUP_DEBUG"
	else
		CONFIG_CHECK="!IOSCHED_BFQ"
	fi
	if use broadcom; then
		CONFIG_CHECK="WLAN_VENDOR_BROADCOM"
	else
		CONFIG_CHECK="!WLAN_VENDOR_BROADCOM"
	fi
	if use btrfs; then
		CONFIG_CHECK="BTRFS_FS"
	else
		CONFIG_CHECK="!BTRFS_FS"
	fi
	use bzip2 && CONFIG_CHECK="KERNEL_BZIP2"
	if use debug; then
		CONFIG_CHECK="KALLSYMS"
	else
		CONFIG_CHECK="!KALLSYMS"
	fi
	if use ext2; then
		CONFIG_CHECK="EXT2_FS"
	else
		CONFIG_CHECK="!EXT2_FS"
	fi
	if use f2fs; then
		CONFIG_CHECK="F2FS_FS F2FS_FS_XATTR F2FS_STAT_FS"
	else
		CONFIG_CHECK="!F2FS_FS"
	fi
	if use fat; then
		CONFIG_CHECK="!FAT_DEFAULT_UTF8 MSDOS_FS NLS_CODEPAGE_437 NLS_ISO8859_1 NLS_UTF8 VFAT_FS"
	else
		CONFIG_CHECK="!VFAT_FS"
	fi
	use gzip && CONFIG_CHECK="KERNEL_GZIP"
	if use hygon; then
		CONFIG_CHECK="CPU_SUP_HYGON"
	else
		CONFIG_CHECK="!CPU_SUP_HYGON"
	fi
	if use intel; then
		CONFIG_CHECK="CPU_SUP_INTEL MICROCODE_INTEL"
		use debug && CONFIG_CHECK="DRM_I915_DEBUG_MMIO"
	else
		CONFIG_CHECK="!CPU_SUP_INTEL"
	fi
	if use ivybridge; then
		CONFIG_CHECK="MIVYBRIDGE"
	else
		CONFIG_CHECK="!MIVYBRIDGE"
	fi
	if use kyber; then
		CONFIG_CHECK="MQ_IOSCHED_KYBER"
	else
		CONFIG_CHECK="!MQ_IOSCHED_KYBER"
	fi
	use lz4 && CONFIG_CHECK="KERNEL_LZ4"
	use lzma && CONFIG_CHECK="KERNEL_LZMA"
	use lzo && CONFIG_CHECK="KERNEL_LZO"
	if use pf-sources && use bmq; then
		CONFIG_CHECK="SCHED_BMQ"
	else
		CONFIG_CHECK="!SCHED_BMQ"
	fi
	if use secure; then
		CONFIG_CHECK="INIT_ON_ALLOC_DEFAULT_ON INIT_ON_FREE_DEFAULT_ON RETPOLINE !USER_NS_UNPRIVILEGED"
	else
		CONFIG_CHECK="USER_NS_UNPRIVILEGED !INIT_ON_ALLOC_DEFAULT_ON !INIT_ON_FREE_DEFAULT_ON !RETPOLINE"
	fi
	use threads-4 && [[ $(getfilevar CONFIG_NR_CPUS /usr/src/linux/.config) != 4 ]] && die "set NR_CPUS to 4"
	use threads-16 && [[ $(getfilevar CONFIG_NR_CPUS /usr/src/linux/.config) != 16 ]] && die "set NR_CPUS to 16"
	if use threads-4 || use threads-16; then
		CONFIG_CHECK="!MAXSMP"
	else
		CONFIG_CHECK="MAXSMP"
	fi
	if use threads-4 || use threads-16 || use threads-512; then
		CONFIG_CHECK="CRYPTO_PCRYPT SMP"
	else
		CONFIG_CHECK="!CRYPTO_PCRYPT !SMP"
	fi
	if use test; then
		CONFIG_CHECK="COMPILE_TEST HEADER_TEST"
	else
		CONFIG_CHECK="!COMPILE_TEST !HEADER_TEST"
	fi
	if use uefi; then
		CONFIG_CHECK="EFI EFI_PARTITION PARTITION_ADVANCED"
	else
		CONFIG_CHECK="!EFI !EFI_PARTITION !PARTITION_ADVANCED"
	fi
	if use xeon; then
		CONFIG_CHECK="INTEL_SPEED_SELECT_INTERFACE"
	else
		CONFIG_CHECK="!INTEL_SPEED_SELECT_INTERFACE"
	fi
	use xz && CONFIG_CHECK="KERNEL_XZ"
	if use zhaoxin; then
		CONFIG_CHECK="CPU_SUP_ZHAOXIN"
	else
		CONFIG_CHECK="!CPU_SUP_ZHAOXIN"
	fi
}

src_install() {
	use dev && newbin "${FILESDIR}"/r.sh r
	use dev && systemd_dounit "${FILESDIR}/${PN}.service"
	use dev && systemd_dounit "${FILESDIR}/${PN}.timer"
}
