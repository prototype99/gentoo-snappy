# Copyright 1999-2018 Gentoo Foundation
# Copyright 2018-2019 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2

EAPI=7
inherit rindeal

## gitlab.eclass:
GITLAB_SVR="https://gitlab.gnome.org"
GITLAB_NS="GNOME"

## python-r1.eclass:
PYTHON_COMPAT=( python3_{5,6,7} )

## functions: rindeal:prefix_flags
inherit rindeal-utils

##
inherit gitlab

## functions: linux-info_pkg_setup
inherit linux-info

## variables: PYTHON_REQUIRED_USE, PYTHON_DEPS
## functions: python_setup
inherit python-r1

## EXPORT_FUNCTIONS: src_prepare pkg_preinst pkg_postinst pkg_postrm
inherit xdg

## functions: gnome2_environment_reset, gnome2_giomodule_cache_update, gnome2_schemas_update
inherit gnome2-utils

## functions: append-cppflags, append-cflags, append-cxxflags
inherit flag-o-matic

## EXPORT_FUNCTIONS: src_configure src_compile src_test src_install
inherit meson

DESCRIPTION="The GLib library of C routines"
HOMEPAGE_A=(
	"https://developer.gnome.org/glib"
	"${GITLAB_HOMEPAGE}"
)
LICENSE_A=(
	'LGPL-2.1-or-later'
)

SLOT="2"
SRC_URI_A=(
	"${GITLAB_SRC_URI}"
)

KEYWORDS_A=(
	'amd64'
	'arm'
	'arm64'
)
IUSE_A=(
	dbus
	debug
	+mime
	selinux
	static-libs
	systemtap
	utils
	xattr
	$(rindeal:prefix_flags "iconv_" \
		+libc  \
		gnu    \
		native \
	)
	man
	+libmount
	doc
	fam
)

# FIXME: verify all deps

CDEPEND_A=(
	"dev-libs/libpcre:3[static-libs?]"
	"virtual/libiconv"
	"virtual/libffi"
	"virtual/libintl"
	"sys-libs/zlib"
	"sys-apps/util-linux"
	"selinux? ( sys-libs/libselinux )"
	"xattr? ( sys-apps/attr )"
	"utils? ("
		"${PYTHON_DEPS}"
		"virtual/libelf:0="
	")"
	"libmount? ( sys-apps/util-linux[libmount] )"
)
DEPEND_A=( "${CDEPEND_A[@]}"
	"doc? ("
		"app-text/docbook-xml-dtd:4.1.2"
		"dev-libs/libxslt"
	")"
	"sys-devel/gettext"  # gettext is required unconditionally
	"systemtap? ( dev-util/systemtap )"
	"${PYTHON_DEPS}"
)
RDEPEND_A=( "${CDEPEND_A[@]}"
	"!<dev-util/gdbus-codegen-${PV}"
)
PDEPEND_A=(
	"dbus? ( gnome-base/dconf )"
	"mime? ( x11-misc/shared-mime-info )"
)

REQUIRED_USE_A=(
	"utils? ( ${PYTHON_REQUIRED_USE} )"
	"^^ ("
		"$(rindeal:prefix_flags "iconv_" \
			libc   \
			gnu    \
			native \
		)"
	")"
)

inherit arrays

L10N_LOCALES=( af am an ar as ast az be be@latin bg bn bn_IN bs ca ca@valencia cs cy da de dz el en@shaw en_CA en_GB eo es et eu fa fi fr fur ga gd gl gu he hi hr hu hy id is it ja ka kk kn ko ku lt lv mai mg mk ml mn mr ms nb nds ne nl nn oc or pa pl ps pt pt_BR ro ru rw si sk sl sq sr sr@ije sr@latin sv ta te tg th tl tr tt ug uk vi wa xh yi zh_CN zh_HK zh_TW )
inherit l10n-r1

pkg_setup()
{
	CONFIG_CHECK="
		~INOTIFY_USER
	"
	linux-info_pkg_setup

	python_setup "python3*"

	GIOMODULE_CACHE="usr/$(get_libdir)/gio/modules/giomodule.cache"
	GSCHEMAS_CACHE="usr/share/glib-2.0/schemas/gschemas.compiled"
}

src_unpack()
{
	gitlab:src_unpack
}

src_prepare:locales()
{
	local l locales dir="po" pre="" post=".po"

	l10n_find_changes_in_dir "${dir}" "${pre}" "${post}"

	l10n_get_locales locales app off
	for l in ${locales}
	do
		NO_V=1 rrm "${dir}/${pre}${l}${post}"
		rsed -e "/${l}/d" -i -- "${dir}/LINGUAS"
	done
}

src_prepare()
{
	eapply_user

	xdg_src_prepare
	gnome2_environment_reset

	src_prepare:locales

	# Don't build tests, also prevents extra deps, bug gentoo#512022
	while read -r m
	do
		rsed -e "/subdir('tests')/d" -i -- "${m}"
	done < <(grep -r --include="meson.build" -e "subdir('tests')" -l .)

	rsed -e '/subdir.*fuzzing/d' -i -- meson.build
}

src_configure()
{
	# ```
	# * ../glib-2.56.1/glib/gmain.h:593:24: warning: the comparison will always evaluate as 'true' for the address of 'g_source_remove' will never be NULL [-Waddress]
	# ```
	append-cflags "-Wno-address"
	append-cxxflags "-Wno-address"

	if use debug
	then
		append-cppflags -DG_ENABLE_DEBUG
	else
		append-cppflags -DG_DISABLE_CAST_CHECKS # https://gitlab.gnome.org/GNOME/glib/issues/1833
	fi

	local emesonargs=(
		# -D runtime_libdir=
		-D iconv="$(
			usex iconv_libc 'libc' "$(
				usex iconv_gnu 'gnu' "$(
					usex iconv_native 'native' 'error'
				)"
			)"
		)"
		# -D charsetalias_dir=
		# -D gio_module_dir=
		-D selinux=$(usex selinux 'enabled' 'disabled')
		$(meson_use xattr)
		$(meson_use libmount)
		-D internal_pcre=false
		$(meson_use man)
		$(meson_use systemtap dtrace)
		$(meson_use systemtap)
		# -D tapset_install_dir=
		$(meson_use doc gtk_doc)
		-D bsymbolic_functions=true
		-D force_posix_threads=false
		$(meson_use fam)
		-D installed_tests=false
		-D nls=enabled  # this needs to be always enabled because of the bugginess of glib's gettext support
	)

	meson_src_configure
}

src_compile()
{
	meson_src_compile
}

src_test(){ :;}

src_install()
{
	meson_src_install
	einstalldocs

	# workaround for python_wrapper_setup messing with PATH
	python_fix_shebang "${ED}/usr/bin/"{gdbus-codegen,glib-genmarshal,glib-mkenums,gtester-report}

	keepdir "/usr/$(get_libdir)/gio/modules"

	# glib-gettextize errors out if this dir doesn't exist
	keepdir "/usr/share/glib-2.0/gettext"

	if use utils
	then
		python_replicate_script "${ED}/usr/bin/gtester-report"
	else
		rrm "${ED}/usr/bin/gtester-report"
	fi

	# Do not install charset.alias even if generated, leave it to libiconv
	rrm -f "${ED}/usr/lib/charset.alias"

	# Don't install gdb python macros, bug 291328
	rrm -r "${ED}/usr/share/gdb/" "${ED}/usr/share/glib-2.0/gdb/"
}

pkg_preinst()
{
	xdg_pkg_preinst

	## Make gschemas.compiled belong to glib alone
	if [[ -e "${EROOT}/${GSCHEMAS_CACHE}" ]]
	then
		rcp "${EROOT}/${GSCHEMAS_CACHE}" "${ED}/${GSCHEMAS_CACHE}"
	else
		touch "${ED}/${GSCHEMAS_CACHE}" || die
	fi

	## Make giomodule.cache belong to glib alone
	if [[ -e ${EROOT}/${GIOMODULE_CACHE} ]]
	then
		rcp "${EROOT}/${GIOMODULE_CACHE}" "${ED}/${GIOMODULE_CACHE}"
	else
		touch "${ED}/${GIOMODULE_CACHE}" || die
	fi
}

pkg_postinst()
{
	xdg_pkg_postinst

	# force (re)generation of gschemas.compiled
	GNOME2_ECLASS_GLIB_SCHEMAS="force"

	gnome2_giomodule_cache_update || die
	gnome2_schemas_update
}

pkg_postrm()
{
	xdg_pkg_postrm

	if [[ -z ${REPLACED_BY_VERSION} ]]
	then
		rrm -f "${EPREFIX}/${GIOMODULE_CACHE}"
		rrm -f "${EPREFIX}/${GSCHEMAS_CACHE}"
	fi

	gnome2_giomodule_cache_update || die
	gnome2_schemas_update
}
