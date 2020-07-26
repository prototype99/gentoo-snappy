# Copyright 2018-2019 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2

if ! (( _E2FSPROGS_ECLASS ))
then

case "${EAPI:-0}" in
'7' ) ;;
* ) die "EAPI='${EAPI}' is not supported by '${ECLASS}' eclass" ;;
esac

inherit rindeal


## cgit.eclass:
CGIT_SVR="https://git.kernel.org"
CGIT_NS="pub/scm/fs/ext2"
CGIT_PROJ="e2fsprogs"
CGIT_DOT_GIT="yes"

##
inherit cgit

## functions: eautoreconf
inherit autotools

## functions: append-cppflags
inherit flag-o-matic

## functions: tc-has-tls, tc-is-static-only
inherit toolchain-funcs

## functions: get_udevdir
inherit udev

## functions: systemd_get_systemunitdir
inherit systemd


HOMEPAGE_A=(
	"http://${PN}.sourceforge.net/"
	"${CGIT_HOMEPAGE}"
	"https://github.com/tytso/${PN}"
)
LICENSE_A=(
	"GPL-2"
	"BSD"
)

SLOT="0"
SRC_URI_A=(
	"${CGIT_SRC_URI}"
)

IUSE_A=(
	static-libs
	debug
# 	threads
)

inherit arrays


EXPORT_FUNCTIONS src_unpack src_prepare src_configure src_compile src_install


e2fsprogs_src_unpack()
{
	cgit:src_unpack
}

e2fsprogs_src_prepare()
{
	eapply_user

	# rename changelog so that einstalldocs() will pick it automagically
	rcp doc/RelNotes/v${PV}.txt ChangeLog

	## don't bother with docs, Gentoo-Bug: 305613
	NO_V=1 rrm -r doc

	rsed -e 's,@LIBINTL@,@LTLIBINTL@,' -i -- MCONFIG.in

	# https://bugs.gentoo.org/686716
	rsed -e "/AM_GNU_GETTEXT/ s/$/([external])/" -i -- configure.ac
	rsed -e "s/ intl//" -i -- Makefile.in

	eautoreconf
}

e2fsprogs_src_configure()
{
	# ```
	# /sbin/ldconfig
	# /sbin/ldconfig: Can't create temporary cache file /etc/ld.so.cache~: Permission denied
	# ```
	export ac_cv_path_LDCONFIG=:

	local -a _econf_args=(
		--enable-option-checking
		--disable-maintainer-mode
		--enable-symlink-install  # use symlinks when installing instead of hard links
		--enable-relative-symlinks  # use relative symlinks when installing
		--enable-symlink-build  # use symlinks while building instead of hard links
		--enable-verbose-makecmds
		$(tc-is-static-only || echo --enable-elf-shlibs)
		--disable-bsd-shlibs
		--disable-profile
		--disable-gcov
		--disable-hardening  # these are just compiler and linker flags
		$(use_enable debug jbd-debug)
		$(use_enable debug blkid-debug)
		$(use_enable debug testio-debug)
		--disable-libuuid  # using newer and better versions from util-linux
		--disable-libblkid  # using newer and better versions from util-linux
		--disable-subset  # enable if needed
		--disable-backtrace
		--disable-debugfs  # enable if needed
		--disable-imager  # enable if needed
		--disable-resizer  # enable if needed
		--disable-defrag  # enable if needed
		--disable-fsck  # using newer and better versions from util-linux
		--disable-e2initrd-helper  # enable if needed
		$(tc-has-tls || echo --disable-tls)
		--disable-uuidd  # using newer and better versions from util-linux
		--disable-mmp  # enable if needed
		--disable-tdb  # enable if needed
		--disable-bmap-stats  # enable if needed
		--disable-bmap-stats-ops  # enable if needed
		--disable-nls  # enable if needed
# 		$(usex threads "--enable-threads=posix" "--disable-threads")
		--disable-rpath
		--disable-fuse2fs  # enable if needed
		--disable-lto  # we can enable it ourselves
		$(use_enable debug ubsan)
		$(use_enable debug addrsan)
		$(use_enable debug threadsan)
		--with-udev-rules-dir="${EPREFIX}$(get_udevdir)/rules.d"
		--without-crond-dir
		--with-systemd-unit-dir="$(systemd_get_systemunitdir)"

		--with-root-prefix="${EPREFIX}"  # ??

		"${@}"
	)

	econf "${_econf_args[@]}"
}

e2fsprogs_src_compile()
{
	local -a _emake_args=(
		V=1
		"${@}"
	)
	emake "${_emake_args[@]}"
}

e2fsprogs_src_install()
{
	local -a _emake_args=(
		STRIP=:
		DESTDIR="${D}"
		install
		"${@}"
	)

	emake "${_emake_args[@]}"

	einstalldocs

	# configure doesn't have an option to disable static libs :/
	if ! use static-libs
	then
		printf -- "* Deleting static libs as requested...\n"
		find "${D}" -name '*.a' -print -delete || die
		echo
	fi
}


_E2FSPROGS_ECLASS=1
fi
