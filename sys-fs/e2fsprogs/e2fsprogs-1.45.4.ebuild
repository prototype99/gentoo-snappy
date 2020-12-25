# Copyright 1999-2018 Gentoo Foundation
# Copyright 2018-2019 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2

EAPI=7
inherit rindeal

## EXPORT_FUNCTIONS src_unpack src_prepare src_configure src_compile src_install
inherit e2fsprogs

## functions: eshopts_push, eshopts_pop
inherit estack

## functions: gen_usr_ldscript
inherit usr-ldscript

DESCRIPTION="Standard EXT2/EXT3/EXT4 filesystem utilities"

KEYWORDS="~amd64 ~arm ~arm64"
IUSE_A=(
	debugfs imager +resizer defrag e2initrd-helper +mmp +tdb bmap-stats bmap-stats-ops nls fuse
	+backtrace
)

CDEPEND_A=(
	"~sys-libs/${PN}-libs-${PV}"
	"sys-apps/util-linux[libblkid,libuuid]"
	"fuse? ( sys-fs/fuse:0 )"
	"nls? ( virtual/libintl )"
)
DEPEND_A=( "${CDEPEND_A[@]}"
	"nls? ( sys-devel/gettext )"
	"virtual/pkgconfig"
)
RDEPEND_A=( "${CDEPEND_A[@]}" )

inherit arrays

src_prepare()
{
	eapply_user

	### BEGIN force separation of libss and libet

	# make sure nothing escapes
	NO_V=1 rrm -r lib/et lib/ss

	rsed -r -e '/^DEP(STATIC_)?LIB(COM_ERR|SS)/ s|=.*|=|' -i -- MCONFIG.in
	rsed -r -e '/^(STATIC_)?LIB(COM_ERR|SS)/ s,[^ \t]+/lib(ss|com_err)@\w*LIB_EXT@,-l\1,g' -i -- MCONFIG.in

	eshopts_push -s globstar
	local f
	for f in **/Makefile.in
	do
		if grep -E -q "/lib/(ss|et)" "${f}"
		then
			rsed -r -e "s,[^ \t]+lib/(ss|et)[^ \t]*,,g" -i -- "${f}"
		fi
	done
	eshopts_pop

	### END

	e2fsprogs_src_prepare
}

src_configure()
{
	local my_econf_args=(
		$(use_enable backtrace)
		$(use_enable debugfs)
		$(use_enable imager)
		$(use_enable resizer)
		$(use_enable defrag)
		$(use_enable e2initrd-helper)

		$(use_enable mmp)
		$(use_enable tdb)
		$(use_enable bmap-stats)
		$(use_enable bmap-stats-ops)
		$(use_enable nls)

		$(use_enable fuse fuse2fs)
	)
	e2fsprogs_src_configure "${my_econf_args[@]}"
}

src_compile()
{
	local -a emake_args=(
		# default values point to internal paths
		COMPILE_ET=compile_et
		MK_CMDS=mk_cmds
	)

	e2fsprogs_src_compile "${emake_args[@]}"
}

src_install()
{
	local -a emake_args=(
		install-libs
	)
	e2fsprogs_src_install "${emake_args[@]}"

	insinto /etc
	doins "${FILESDIR}"/e2fsck.conf

	# Move shared libraries to /lib/, install static libraries to
	# /usr/lib/, and install linker scripts to /usr/lib/.
	gen_usr_ldscript -a e2p ext2fs
}
