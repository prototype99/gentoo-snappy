# Copyright 1999-2016 Gentoo Foundation
# Copyright 2016-2019 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2

EAPI=7
inherit rindeal

# TODO: revamp USE-flags for better readability/maintainability

## github.eclass:
GITHUB_NS="karelzak"
GITHUB_REF="v${PV}"

## python-*.eclass:
PYTHON_COMPAT=( python2_7 python3_{5,6,7} )

## functions: dsf:eval
inherit dsf-utils

##
inherit github

## TODO: make it python-r1
inherit python-single-r1

## functions: eautoreconf
inherit autotools

## functions: elibtoolize
inherit libtool

## functions: get_bashcompdir
inherit bash-completion-r1

## functions: systemd_get_systemunitdir
inherit systemd

## functions: prune_libtool_files
inherit ltprune

## functions: gen_usr_ldscript
inherit usr-ldscript

## functions: newpamd
inherit pam

DESCRIPTION="Various useful system utilities for Linux"
HOMEPAGE_A=(
	"${GITHUB_HOMEPAGE}"
)
LICENSE_A=(
	"GPL-2"
	"LGPL-2.1"
	"BSD-4"
	"MIT"
	"public-domain"
)

SLOT="0"
SRC_URI_A=(
	"${GITHUB_SRC_URI}"
)

KEYWORDS="amd64 arm arm64"
IUSE_A=(
	doc libpython test nls +shared-libs static-libs +assert +symvers +largefile +unicode

	# TODO: categorize these
	+suid selinux audit +udev +ncurses systemd +pam

	+libblkid
	+libfdisk
	+libmount libmount-support-mtab
	+libsmartcols
	+libuuid libuuid-force-uuidd

	+agetty
	bfs
	+cal
	chfn-chsh chfn-chsh-password +chsh-only-listed
	cramfs
	eject
	+fallocate
	fdformat
	+fsck
	+hwclock
	ipcrm
	ipcs
	+kill
	last
	line
	+logger
	login login-chown-vcs login-stat-mail
	+losetup
	lslogins
	mesg
	minix
	+more
	+mount
	+mountpoint
	newgrp
	nologin
	+nsenter
	+partx
	pg pg-bell
	pivot_root
	+raw
	+rename
	runuser # bound to su
	+schedutils
	+setpriv
	+setterm
	su # bound to runuser
	+sulogin
	switch_root
	tunelp
	ul
	+unshare
	utmpdump
	vipw
	wall
	+wdctl
	write
	zramctl

	uuidd
	pylibmount

	+colors-default
	plymouth-support
	sulogin-emergency-mount
	use-tty-group
	usrdir-path

	btrfs
	+cap-ng
	+libz
	+readline
	slang
	smack
	tinfo
	user
	utempter
	+util

	# extras:
	+fdisk +sfdisk +cfdisk
	+uuidgen +uuidparse +blkid +findfs +wipefs +findmnt blkzone
	+mkfs isosize +fstrim +swapon +lsblk +lscpu
	chcpu
	swaplabel +mkswap
	look mcookie +namei +whereis +getopt +blockdev +prlimit +lslocks
	+flock ipcmk
	lsipc +lsns +renice rfkill +setsid readprofile +dmesg ctrlaltdel +fsfreeze +blkdiscard ldattach rtcwake setarch +script +scriptreplay +col colcrt colrm +column +hexdump +rev fincore
	+ionice +taskset +chrt

	hardlink
	choom
)

CDEPEND_A=(
	# `PKG_CHECK_MODULES([SELINUX], [libselinux >= 2.0],`
	"selinux? ( >=sys-libs/libselinux-2.0 )"
	# `UL_CHECK_LIB([audit]`
	"audit? ( sys-process/audit )"
	# `UL_CHECK_LIB([udev]`
	"udev? ( virtual/libudev:= )"

	# `UL_NCURSES_CHECK([ncursesw])`
	# `UL_NCURSES_CHECK([ncurses])`
	"ncurses? ( >=sys-libs/ncurses-5.2-r2:0=[unicode?] )"
	# `AC_CHECK_HEADERS([slang.h slang/slang.h])`
	# `AC_CHECK_HEADERS([slcurses.h slang/slcurses.h],`
	"slang? ( sys-libs/slang )"
	# `UL_TINFO_CHECK([tinfow])`
	# `UL_TINFO_CHECK([tinfo])`
	"tinfo? ( sys-libs/ncurses:*[tinfo] )"
	# `UL_CHECK_LIB([readline], [readline])`
	"readline? ( sys-libs/readline:0= )"
	# `UL_CHECK_LIB([utempter], [utempter_add_record])`
	"utempter? ( sys-libs/libutempter:0 )"
	# `UL_CHECK_LIB([cap-ng], [capng_apply], [cap_ng])`
	"cap-ng? ( sys-libs/libcap-ng )"
	# `AC_CHECK_LIB([z], [crc32]`
	"libz? ( sys-libs/zlib )"
	# `PKG_CHECK_MODULES(LIBUSER,[libuser >= 0.58]`
	"user? ( sys-libs/libuser )"
	# `AS_CASE([$with_btrfs:$have_linux_btrfs_h],`
	"btrfs? ( sys-fs/btrfs-progs )"
	# `PKG_CHECK_MODULES([SYSTEMD], [libsystemd], [have_systemd=yes], [have_systemd=no])`
	"systemd? ( sys-apps/systemd )"
	"pam? ( sys-libs/pam )"
	"libpython? ( ${PYTHON_DEPS} )"
)
DEPEND_A=( "${CDEPEND_A[@]}"
	"virtual/pkgconfig"
	"nls?	( sys-devel/gettext )"
	"test?	( sys-devel/bc )"
	"sys-kernel/linux-headers:0"
)
RDEPEND_A=( "${CDEPEND_A[@]}"
	"kill? ("
		"!sys-apps/coreutils[kill]"
		"!sys-process/procps[kill]"
	")"
	"schedutils? ( !sys-process/schedutils )"
	"eject? ( !sys-block/eject )"
	"!<app-shells/bash-completion-2.3-r2"
	"rfkill? ( !net-wireless/rfkill )"

	## collisions with `shadow`
	"vipw?      ( !sys-apps/shadow[vipw-vigr] )"
	"newgrp?    ( !sys-apps/shadow[newgrp] )"
	"su?        ( !sys-apps/shadow[su] )"
	"login?     ( !sys-apps/shadow[login] )"
	"nologin?   ( !sys-apps/shadow[nologin] )"
	"chfn-chsh? ( !sys-apps/shadow[chfn-chsh] )"
)

REQUIRED_USE_A=(
	"libpython? ( ${PYTHON_REQUIRED_USE} )"
	# curses lib is selected via `CURSES_LIB_NAME`, which can be one of:
	#     ncurses ncursesw slang
	"?? ( ncurses slang )"
	# `UL_REQUIRES_BUILD([libfdisk], [libuuid])`
	"libfdisk? ( libuuid )"
	# `UL_REQUIRES_BUILD([libmount], [libblkid])`
	"libmount? ( libblkid )"
	# `UL_REQUIRES_BUILD([fdisk], [libfdisk])`
	# `UL_REQUIRES_BUILD([fdisk], [libsmartcols])`
	"fdisk? ( libfdisk libsmartcols )"
	# `UL_REQUIRES_BUILD([sfdisk], [libfdisk])`
	# `UL_REQUIRES_BUILD([sfdisk], [libsmartcols])`
	"sfdisk? ( libfdisk libsmartcols )"
	# `UL_REQUIRES_BUILD([cfdisk], [libfdisk])`
	# `UL_REQUIRES_BUILD([cfdisk], [libsmartcols])`
	# `UL_REQUIRES_HAVE([cfdisk], [ncursesw,slang,ncurses], [ncursesw, ncurses or slang library])`
	"cfdisk? ( libfdisk libsmartcols || ( ncurses slang ) )"
	# `UL_REQUIRES_BUILD([mount], [libmount])`
	"mount? ( libmount )"
	# `UL_REQUIRES_BUILD([losetup], [libsmartcols])`
	"losetup? ( libsmartcols )"
	# `UL_REQUIRES_BUILD([zramctl], [libsmartcols])`
	"zramctl? ( libsmartcols )"
	# `UL_REQUIRES_BUILD([fsck], [libmount])`
	"fsck? ( libmount )"
	# `UL_REQUIRES_BUILD([partx], [libblkid])`
	# `UL_REQUIRES_BUILD([partx], [libsmartcols])`
	"partx? ( libblkid libsmartcols )"
	# `UL_REQUIRES_BUILD([uuidd], [libuuid])`
	"uuidd? ( libuuid )"
	# `UL_REQUIRES_BUILD([uuidgen], [libuuid])`
	"uuidgen? ( libuuid )"
	# `UL_REQUIRES_BUILD([uuidparse], [libuuid])`
	# `UL_REQUIRES_BUILD([uuidparse], [libsmartcols])`
	"uuidparse? ( libuuid libsmartcols )"
	# `UL_REQUIRES_BUILD([blkid], [libblkid])`
	"blkid? ( libblkid )"
	# `UL_REQUIRES_BUILD([findfs], [libblkid])`
	"findfs? ( libblkid )"
	# `UL_REQUIRES_BUILD([wipefs], [libblkid])`
	# `UL_REQUIRES_BUILD([wipefs], [libsmartcols])`
	"wipefs? ( libblkid libsmartcols )"
	# `UL_REQUIRES_BUILD([findmnt], [libmount])`
	# `UL_REQUIRES_BUILD([findmnt], [libblkid])`
	# `UL_REQUIRES_BUILD([findmnt], [libsmartcols])`
	"findmnt? ( libmount libblkid libsmartcols )"
	# `UL_REQUIRES_BUILD([mountpoint], [libmount])`
	"mountpoint? ( libmount )"
	# `UL_REQUIRES_HAVE([setpriv], [cap_ng], [libcap-ng library])`
	"setpriv? ( cap-ng )"
	# `UL_REQUIRES_BUILD([eject], [libmount])`
	"eject? ( libmount )"
	# `UL_REQUIRES_HAVE([cramfs], [z], [z library])`
	"cramfs? ( libz )"
	# `UL_REQUIRES_BUILD([fstrim], [libmount])`
	"fstrim? ( libmount )"
	# `UL_REQUIRES_BUILD([swapon], [libblkid])`
	# `UL_REQUIRES_BUILD([swapon], [libmount])`
	# `UL_REQUIRES_BUILD([swapon], [libsmartcols])`
	"swapon? ( libblkid libmount libsmartcols )"
	# `UL_REQUIRES_BUILD([lsblk], [libblkid])`
	# `UL_REQUIRES_BUILD([lsblk], [libmount])`
	# `UL_REQUIRES_BUILD([lsblk], [libsmartcols])`
	"lsblk? ( libblkid libmount libsmartcols )"
	# `UL_REQUIRES_BUILD([lscpu], [libsmartcols])`
	"lscpu? ( libsmartcols )"
	# `UL_REQUIRES_BUILD([lslogins], [libsmartcols])`
	"lslogins? ( libsmartcols )"
	# `UL_REQUIRES_BUILD([wdctl], [libsmartcols])`
	"wdctl? ( libsmartcols )"
	# `UL_REQUIRES_BUILD([swaplabel], [libblkid])`
	"swaplabel? ( libblkid )"
	# `UL_REQUIRES_BUILD([prlimit], [libsmartcols])`
	"prlimit? ( libsmartcols )"
	# `UL_REQUIRES_BUILD([lslocks], [libmount])`
	# `UL_REQUIRES_BUILD([lslocks], [libsmartcols])`
	"lslocks? ( libmount libsmartcols )"
	# `UL_REQUIRES_BUILD([lsipc], [libsmartcols])`
	"lsipc? ( libsmartcols )"
	# `UL_REQUIRES_BUILD([lsns], [libsmartcols])`
	"lsns? ( libsmartcols )"
	# `UL_REQUIRES_BUILD([rfkill], [libsmartcols])`
	"rfkill? ( libsmartcols )"
	# `UL_REQUIRES_BUILD([fincore], [libsmartcols])`
	"fincore? ( libsmartcols )"
	# `UL_REQUIRES_BUILD([column], [libsmartcols])`
	"column? ( libsmartcols )"
	# `UL_REQUIRES_HAVE([chfn_chsh], [security_pam_appl_h], [PAM header file])`
	"$(dsf:eval 'chfn-chsh-password|user' 'pam')"
	# `UL_REQUIRES_HAVE([login], [security_pam_appl_h], [PAM header file])`
	"login? ( pam )"
	# `UL_REQUIRES_HAVE([su], [security_pam_appl_h], [PAM header file])`
	"su? ( pam )"
	# `UL_REQUIRES_HAVE([runuser], [security_pam_appl_h], [PAM header file])`
	"runuser? ( pam )"
	# `UL_REQUIRES_HAVE([ul], [ncursesw, tinfo, ncurses], [ncursesw, ncurses or tinfo libraries])`
	"ul? ( || ( ncurses tinfo ) )"
	# `UL_REQUIRES_HAVE([more], [ncursesw, tinfo, ncurses, termcap], [ncursesw, ncurses, tinfo or termcap libraries])`
	"more? ( || ( ncurses tinfo ) )"
	# `UL_REQUIRES_HAVE([pg], [ncursesw, ncurses], [ncursesw or ncurses library])`
	"pg? ( ncurses )"
	# `UL_REQUIRES_HAVE([setterm], [ncursesw, ncurses], [ncursesw or ncurses library])`
	"setterm? ( ncurses )"
	# `UL_REQUIRES_BUILD([ionice], [schedutils])`
	"ionice? ( schedutils )"
	# `UL_REQUIRES_BUILD([taskset], [schedutils])`
	"taskset? ( schedutils )"
	# `UL_REQUIRES_BUILD([chrt], [schedutils])`
	"chrt? ( schedutils )"
	# `UL_REQUIRES_HAVE([pylibmount], [libpython], [libpython])`
	# `UL_REQUIRES_BUILD([pylibmount], [libmount])`
	"pylibmount? ( libpython libmount )"
)

inherit arrays

L10N_LOCALES=( ca cs da de es et eu fi fr gl hr hu id it ja nl pl pt_BR ru sl sv tr uk vi zh_CN zh_TW )
inherit l10n-r1

pkg_setup()
{
	use libpython && python-single-r1_pkg_setup
}

src_unpack()
{
	github:src_unpack
}

src_prepare:locales()
{
	local l locales dir="po" pre="" post=".po"

	l10n_find_changes_in_dir "${dir}" "${pre}" "${post}"

	if use nls
	then
		l10n_get_locales locales app off
		for l in ${locales}
		do
			rrm "${dir}/${pre}${l}${post}"
		done
	else
		NO_V=1 rrm -r po/
		rsed -e "/AM_GNU_GETTEXT/d" -e "\@po/@d" -i -- configure.ac
		rsed -e "/SUBDIRS/ s, po, ," -i -- Makefile.am
	fi
}

## although my_use_build_init is src_configure-type function,
## it edits configure.ac, therefore it must be src_prepare type.
src_prepare:build_init()
{
	local -A used_options=()

	my_use_build_init()
	{
		local flag="${1}" option="${2:-"${1}"}"
		[[ -v "used_options[${option}]" ]] && die "duplicated option"
		used_options+=( ["${option}"]="" )
		grep -F -q -e "UL_BUILD_INIT([${option}]" -- configure.ac || die
		rsed -r -e "s@^(UL_BUILD_INIT *\( *\[${option}\])(, *\[[a-z]{2,}\])?@\1, [$(usex ${flag})]@" \
			-i -- configure.ac
	}

	my_use_build_init fdisk
	my_use_build_init sfdisk
	my_use_build_init cfdisk

	my_use_build_init uuidgen
	my_use_build_init uuidparse
	my_use_build_init blkid
	my_use_build_init findfs
	my_use_build_init wipefs
	my_use_build_init findmnt
	my_use_build_init blkzone

	my_use_build_init mkfs
	my_use_build_init isosize
	my_use_build_init fstrim
	my_use_build_init swapon
	my_use_build_init lsblk
	my_use_build_init lscpu

	my_use_build_init chcpu

	my_use_build_init swaplabel
	my_use_build_init mkswap

	my_use_build_init look
	my_use_build_init mcookie
	my_use_build_init namei
	my_use_build_init whereis
	my_use_build_init getopt
	my_use_build_init blockdev
	my_use_build_init prlimit
	my_use_build_init lslocks

	my_use_build_init flock
	my_use_build_init ipcmk

	my_use_build_init lsipc
	my_use_build_init lsns
	my_use_build_init fincore
	my_use_build_init renice
	my_use_build_init rfkill
	my_use_build_init setsid
	my_use_build_init readprofile
	my_use_build_init dmesg
	my_use_build_init ctrlaltdel
	my_use_build_init fsfreeze
	my_use_build_init blkdiscard
	my_use_build_init ldattach
	my_use_build_init rtcwake
	my_use_build_init setarch
	my_use_build_init script
	my_use_build_init scriptreplay
	my_use_build_init col
	my_use_build_init colcrt
	my_use_build_init colrm
	my_use_build_init column
	my_use_build_init hexdump
	my_use_build_init rev

	my_use_build_init ionice
	my_use_build_init taskset
	my_use_build_init chrt

	my_use_build_init hardlink  # TODO: new additions -> categorize
	my_use_build_init choom     # TODO: new additions -> categorize

	local -- configure_status_msg
	read -r -d '' configure_status_msg <<-_EOF_
	AC_MSG_RESULT([
	The resulting build status:
	- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

	$(
		gawk -e '
			BEGIN {
				re  = "\\$(build|enable|have)_([a-zA-Z0-9_-]{2,})"
			}
			{
				if (!match($0, re, m))
					next
				a[m[2], m[1]]
			}
			END {
				asorti(a)
				for (i in a)
				{
					split(a[i], x, SUBSEP)
					opt = x[1]
					cat = x[2]
					varname = sprintf("%s_%s", cat, opt)
					printf("%-18s: \\$%-25s = $%s\n", opt, varname, varname)
				}
			}
		' -- configure.ac
	)

	- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	])
	_EOF_
	printf -- "%s" "${configure_status_msg}" >> configure.ac || die
}

src_prepare()
{
	# https://github.com/karelzak/util-linux/pull/878
	eapply "${FILESDIR}/po-update-potfiles-find.patch"

	eapply_user

	if use nls
	then
		## generate POTFILES.in file used by GNU l10n tools
		po/update-potfiles  # required step taken from autogen.sh
	fi
	src_prepare:locales

	# Set version manually, otherwise it uses a script which derives the version from ".tarball-version" file or git.
	#
	# AC_PACKAGE_VERSION, PACKAGE_VERSION get initialized from this file via `./tools/git-version-gen` script
	# Fixes: https://github.com/rindeal/gentoo-overlay/issues/157
	rsed -r -e "s@m4_esyscmd\(.*\.tarball-version.*\)@[${PV}]@" -i -- configure.ac

	src_prepare:build_init

	eautoreconf
	elibtoolize
}

src_configure()
{
	export ac_cv_header_security_pam_misc_h="$(usex pam)" # gentoo#485486
	export ac_cv_header_security_pam_appl_h="$(usex pam)" # gentoo#545042

	local -a my_econf_args=(
		--enable-fs-paths-extra="${EPREFIX}/usr/sbin:${EPREFIX}/bin:${EPREFIX}/usr/bin"
		--docdir="\${datarootdir}/doc/${PF}"

		## BASH completion
		--with-bashcompletiondir="$(get_bashcompdir)"
		--enable-bash-completion
		--with-systemdsystemunitdir="$(systemd_get_systemunitdir)"

		# do not ever set this, it disables utils even if all their deps are met
		# --disable-all-programs

		## TODO: reorganize these options according to ./configure --help

		$(tc-has-tls || echo --disable-tls)	# disable use of thread local support

		$(use_enable doc gtk-doc)	# use gtk-doc to build documentation
		$(use_enable assert)
		$(use_enable symvers)
		$(use_enable largefile)
		$(usex nls "--enable-nls" "")
		--disable-asan
		$(use_enable shared-libs shared)
		$(use_enable static-libs static)

		$(use_enable unicode widechar) # compile wide character support

		$(use_enable libuuid)
		$(use_enable libuuid-force-uuidd)
		$(use_enable libblkid)
		$(use_enable libmount)
		$(use_enable libmount-support-mtab)
		$(use_enable libsmartcols)
		$(use_enable libfdisk)
		$(use_enable mount)
		$(use_enable losetup)
		$(use_enable zramctl)
		$(use_enable fsck)
		$(use_enable partx)
		$(use_enable uuidd)
		$(use_enable mountpoint)
		$(use_enable fallocate)
		$(use_enable unshare)
		$(use_enable nsenter)
		$(use_enable setpriv)
		$(use_enable hardlink)
		$(use_enable eject)
		$(use_enable agetty)
		$(use_enable plymouth-support plymouth_support)
		$(use_enable cramfs)
		$(use_enable bfs)
		$(use_enable minix)
		$(use_enable fdformat)
		$(use_enable hwclock)
		$(use_enable lslogins)
		$(use_enable wdctl)
		$(use_enable cal)
		$(use_enable logger)
		$(use_enable switch_root)
		$(use_enable pivot_root)
		$(use_enable ipcrm)
		$(use_enable ipcs)
		$(use_enable rfkill)
		$(use_enable tunelp)
		$(use_enable kill)
		$(use_enable last)
		$(use_enable utmpdump)
		$(use_enable line)
		$(use_enable mesg)
		$(use_enable raw)
		$(use_enable rename)
		$(use_enable vipw)
		$(use_enable newgrp)

		$(use_enable chfn-chsh-password)
		$(use_enable chfn-chsh)
		$(use_enable chsh-only-listed)
		$(use_enable login)
		$(use_enable login-chown-vcs)
		$(use_enable login-stat-mail)
		$(use_enable nologin)
		$(use_enable sulogin)
		$(use_enable su)
		$(use_enable runuser)
		$(use_enable ul)
		$(use_enable more)
		$(use_enable pg)
		$(use_enable setterm)
		$(use_enable schedutils)
		$(use_enable wall)
		$(use_enable write)
		$(use_enable pylibmount)
		$(use_enable pg-bell)
# 		$(use_enable fs-paths-default)	# default search path for fs helpers [/sbin:/sbin/fs.d:/sbin/fs]
# 		$(use_enable fs-paths-extra)	# additional search paths for fs helpers
		$(use_enable use-tty-group)
		$(use_enable sulogin-emergency-mount)
		$(use_enable usrdir-path)
		$(use_enable suid makeinstall-chown)	# do not do chown-like operations during "make install"
		$(use_enable suid makeinstall-setuid)	# do not do setuid chmod operations during "make install"
		$(use_enable colors-default)

		$(use_with util)
		$(use_with selinux)
		$(use_with audit)
		$(use_with udev)

		# build with non-wide ncurses, default is wide version (--without-ncurses disables all ncurses(w) support)
		--with-ncurses="$(usex ncurses "$(usex unicode auto yes)" no)"
		$(use_with slang)
		$(use_with tinfo)	# compile without libtinfo
		$(use_with readline)

		$(use_with utempter)
		$(use_with cap-ng)
		$(use_with libz)
		$(use_with user)
		$(use_with btrfs)
		$(use_with systemd)
		$(use_with smack)
		$(use_with libpython python)	# do not build python bindings, use --with-python={2,3} to force version

		# link static the programs in LIST (comma-separated,
		#                  supported for losetup, mount, umount, fdisk, sfdisk, blkid, nsenter, unshare)
# 		--enable-static-programs=
	)

	econf "${my_econf_args[@]}"
}

src_install()
{
	default

	dodoc -r Documentation/

	NO_V=1 rrm "${ED}/usr/share/doc/${PF}/"{AUTHORS,ChangeLog,NEWS,README.licensing}
	NO_V=1 rrm -r "${ED}/usr/share/doc/${PF}/Documentation/licenses"

	rdosym --rel -- "/usr/share/doc/${PF}/"{Documentation/releases/"v${PV}-ReleaseNotes",ChangeLog}

	if use runuser
	then
		# files taken from sys-auth/pambase
		newpamd "${FILESDIR}/runuser.pamd" runuser
		newpamd "${FILESDIR}/runuser-l.pamd" runuser-l
	fi

	prune_libtool_files

	# need the libs in /
	local -a gul_args=(
		$(usex libblkid blkid '')
		$(usex mount mount '')
		$(usex libsmartcols smartcols '')
		$(usex libuuid uuid '')
	)
	(( ${#gul_args[@]} )) && gen_usr_ldscript -a "${gul_args[@]}"

	use libpython && python_optimize
}
