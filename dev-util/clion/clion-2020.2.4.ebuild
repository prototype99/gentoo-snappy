# Copyright 1999-2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7
inherit rindeal

JBIJ_PN_PRETTY='CLion'
inherit jetbrains-intellij

DESCRIPTION="A complete toolset for C and C++ development"
HOMEPAGE="https://www.jetbrains.com/clion"
SRC_URI="https://download.jetbrains.com/cpp/CLion-${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="|| ( IDEA IDEA_Academic IDEA_Classroom IDEA_OpenSource IDEA_Personal )
	Apache-1.1 Apache-2.0 BSD BSD-2 CC0-1.0 CDDL-1.1 CPL-0.5 CPL-1.0
	EPL-1.0 EPL-2.0 GPL-2 GPL-2-with-classpath-exception GPL-3 ISC JDOM
	LGPL-2.1+ LGPL-3 MIT MPL-1.0 MPL-1.1 OFL public-domain PSF-2 UoI-NCSA ZLIB"
KEYWORDS="~amd64 ~arm ~x86"
IUSE="custom-jdk +python +system-clang +system-cmake +system-gdb +system-lldb"

RDEPEND="
	dev-libs/libdbusmenu
	system-clang? ( sys-devel/clang )
	system-cmake? ( >=dev-util/cmake-3.14.3 )
	system-gdb?   ( >=sys-devel/gdb-8.2 )
	system-lldb?  ( >=dev-util/lldb-7.0.1 )"

src_unpack() {
	local JBIJ_TAR_EXCLUDE=( 'lib/pty4j-native/linux/ppc64le' )
	use amd64 || JBIJ_TAR_EXCLUDE+=( 
		'bin/fsnotifier64'
		'lib/pty4j-native/linux/x86_64'
	)
	use python        || JBIJ_TAR_EXCLUDE+=( 'plugins/python' )
	use system-clang  && JBIJ_TAR_EXCLUDE+=( 'bin/clang' )
	use system-cmake  && JBIJ_TAR_EXCLUDE+=(
		'bin/cmake'
		'license/CMake'
	)
	use system-gdb    && JBIJ_TAR_EXCLUDE+=( 'bin/gdb' )
	use system-lldb   && JBIJ_TAR_EXCLUDE+=( 'bin/lldb' )
	use x86 || JBIJ_TAR_EXCLUDE+=( 
		'bin/fsnotifier'
		'lib/pty4j-native/linux/x86'
	)

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

	# recommended by: https://confluence.jetbrains.com/display/IDEADEV/Inotify+Watches+Limit
	dodir /usr/lib/sysctl.d/
	echo "fs.inotify.max_user_watches = 524288" > "${D}/usr/lib/sysctl.d/30-clion-inotify-watches.conf" || die
}
