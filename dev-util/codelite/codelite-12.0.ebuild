# Copyright 2016-2018 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2

EAPI=6
inherit rindeal

## wxwidgets.eclass
WX_GTK_VER="3.0"

## git-hosting.eclass
GH_RN='github:eranif'

## EXPORT_FUNCTIONS: src_unpack
inherit git-hosting

## functions: setup-wxwidgets
inherit wxwidgets

## EXPORT_FUNCTIONS: src_prepare, src_configure, src_compile, src_test, src_install
inherit cmake-utils

## EXPORT_FUNCTIONS: src_prepare, pkg_preinst, pkg_postinst, pkg_postrm
inherit xdg

DESCRIPTION="Free, open source, cross platform C,C++,PHP and Node.js IDE"
HOMEPAGE="https://www.codelite.org ${GH_HOMEPAGE}"
LICENSE="GPL-2"

SLOT="0"

KEYWORDS="~amd64"
IUSE_A=( +clang flex lldb mysql pch sftp webview +wxAuiNotebook wxCrafter +plugins )

CDEPEND_A=(
	"dev-db/sqlite:3"
	"x11-libs/wxGTK:3.0"
	"|| ( x11-libs/gtk+:3 x11-libs/gtk+:2 )"

	"clang? ( sys-devel/clang:* )"
	"lldb? ( dev-util/lldb )"
	"mysql? ( virtual/mysql )"
	"sftp? ( net-libs/libssh )"
)
DEPEND_A=( "${CDEPEND_A[@]}"
	"flex? ( sys-devel/flex )"
)
RDEPEND_A=( "${CDEPEND_A[@]}" )

REQUIRED_USE_A=(
	"sftp? ( plugins )"
	"lldb? ( plugins )"
)

inherit arrays

CHECKREQS_DISK_BUILD='2G'
inherit check-reqs

L10N_LOCALES=( cs ru_RU zh_CN )
inherit l10n-r1

src_prepare-locales() {
	local l locales dir="translations" pre="" post="/LC_MESSAGES/codelite.mo"

	l10n_find_changes_in_dir "${dir}" "${pre}" "${post}"

	l10n_get_locales locales app off
	for l in ${locales} ; do
		rrm -r "${dir}/${l}"
	done
}

pkg_setup() {
	setup-wxwidgets
}

src_prepare() {
	eapply "${FILESDIR}/codelite_dont_strip.patch"
	eapply_user

	src_prepare-locales

	# respect CXXFLAGS
	rsed -e '/set.*CMAKE_CXX_FLAGS/ s|-O2| |' -i -- CMakeLists.txt

	rsed -e '/# *define USE_AUI_NOTEBOOK/d' -i -- CodeLite/cl_defs.h

	xdg_src_prepare
	cmake-utils_src_prepare
}

src_configure() {
	my_usex() {
		usex $1 1 0
	}

	local mycmakeargs=(
		-D WITH_FLEX=$(my_usex flex)
		# no automagic ccache
		-D CCACHE_FOUND=false
		-D ENABLE_LLDB=$(my_usex lldb)
		-D ENABLE_SFTP=$(my_usex sftp)
		-D WITH_PCH=$(my_usex pch)
		-D ENABLE_CLANG=$(my_usex clang)
		-D WITH_WXC=$(my_usex wxCrafter)
		-D COPY_WX_LIBS=0  # do not package the wx libs
		-D USE_AUI_NOTEBOOK=$(my_usex wxAuiNotebook)
		-D MAKE_DEB=0
		-D NO_CORE_PLUGINS=$(usex "!plugins")

		# `sdk/databaselayer/CMakeLists.txt`
		# `DatabaseExplorer/CMakeLists.txt`
		-D WITH_MYSQL=$(my_usex mysql)
	)
	if use plugins ; then
		mycmakeargs+=(
			# `codelitephp/CMakeLists.txt`
			-D WITH_WEBVIEW=$(my_usex webview)
		)
	fi

	if use clang ; then
		local clang_path="$(type -a -p clang 2>/dev/null | grep -v ccache | head -1)"
		[[ -z "${clang_path}" ]] && die
		local clang_root_path="${clang_path%%"/bin/clang"}"
		mycmakeargs+=(
			-D LIBCLANG_T="${clang_root_path}/$(get_libdir)/libclang.so"
			-D LIBCLANG_INCLUDE_T="${clang_root_path}/include"
		)
	fi

	cmake-utils_src_configure
}

src_install() {
	cmake-utils_src_install

	rrm "${ED}"/usr/share/applications/${PN}.desktop
	local make_desktop_entry_args=(
		"${PN} %f"    # exec
		"CodeLite"	# name
		"${PN}"		# icon
		'Development;IDE;' # categories; https://standards.freedesktop.org/menu-spec/latest/apa.html
	)
	local make_desktop_entry_extras=(
# 		'MimeType=;' # TODO
		"StartupNotify=true"
	)
	make_desktop_entry "${make_desktop_entry_args[@]}" \
		"$( printf '%s\n' "${make_desktop_entry_extras[@]}" )"
}
