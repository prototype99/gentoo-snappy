# Copyright 2016, 2019 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2

EAPI=7
inherit rindeal

## jetbrains-intellij.eclass:
JBIJ_PN_PRETTY='CLion'
JBIJ_URI="cpp/CLion-${PV}"

## EXPORT_FUNCTIONS: src_unpack src_prepare src_compile pkg_preinst src_install pkg_postinst pkg_postrm
inherit jetbrains-intellij

DESCRIPTION="Complete toolset for C and C++ development"

IUSE_A=( +python system-clang system-cmake system-gdb system-lldb )

RDEPEND_A=(
	"system-clang? ( sys-devel/clang:8 )"
	"system-cmake? ( >=dev-util/cmake-3.14.3 )"
	"system-gdb?   ( >=sys-devel/gdb-8.2 )"
	"system-lldb?  ( >=dev-util/lldb-7.0.1 )"
)

inherit arrays

src_unpack() {
	local JBIJ_TAR_EXCLUDE=()
	use python        || JBIJ_TAR_EXCLUDE+=( 'plugins/python' )
	use system-clang  && JBIJ_TAR_EXCLUDE+=( 'bin/clang' )
	use system-cmake  && JBIJ_TAR_EXCLUDE+=( 'bin/cmake' )
	use system-gdb    && JBIJ_TAR_EXCLUDE+=( 'bin/gdb' )
	use system-lldb   && JBIJ_TAR_EXCLUDE+=( 'bin/lldb' )

	jetbrains-intellij_src_unpack
}

src_install() {
	local JBIJ_DESKTOP_EXTRAS=(
		"MimeType=text/plain;text/x-c;text/x-h;" # MUST end with semicolon
	)

	jetbrains-intellij_src_install

	cd "${D}/${JBIJ_INSTALL_DIR}" || die
	# globbing doesn't work with `fperms()`'
	use system-clang  || { chmod -v a+x bin/clang/linux/*     || die ;}
	use system-cmake  || { chmod -v a+x bin/cmake/linux/bin/* || die ;}
	use system-gdb    || { chmod -v a+x bin/gdb/linux/bin/*   || die ;}
	use system-lldb   || { chmod -v a+x bin/lldb/linux/bin/*  || die ;}
}
