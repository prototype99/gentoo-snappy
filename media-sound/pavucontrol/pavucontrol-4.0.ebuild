# Copyright 2016-2017,2019 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2

EAPI=7
inherit rindeal

## gitlab.eclass:
GITLAB_SVR="https://gitlab.freedesktop.org"
GITLAB_NS="pulseaudio"
GITLAB_REF="v${PV}"

##
inherit gitlab

## EXPORT_FUNCTIONS: src_prepare pkg_preinst pkg_postinst pkg_postrm
inherit xdg

## functions: eautoreconf
inherit autotools

## functions: append-cxxflags, append-cppflags
inherit flag-o-matic

DESCRIPTION="Pulseaudio Volume Control, GTK based mixer for Pulseaudio"
HOMEPAGE_A=(
	"https://freedesktop.org/software/pulseaudio/pavucontrol/"
	"${GITLAB_HOMEPAGE}"
)
LICENSE="GPL-2"

SLOT="0"

SRC_URI_A=(
	"${GITLAB_SRC_URI}"
)

KEYWORDS="amd64"
IUSE_A=(
	nls
)

CDEPEND_A=(
	">=dev-libs/libsigc++-2.0:2"
	">=media-sound/pulseaudio-5[glib]"

	">=dev-cpp/gtkmm-3.0:3.0"
	">=media-libs/libcanberra-0.16[gtk3]"
)
DEPEND_A=( "${CDEPEND_A[@]}"
	"virtual/pkgconfig"
	"dev-util/intltool"
	"sys-devel/gettext"
)
RDEPEND_A=( "${CDEPEND_A[@]}"
	"virtual/freedesktop-icon-theme"
)

inherit arrays

L10N_LOCALES=( as bn_IN ca ca@valencia cs da de el es fi fr gu hi hr hu it ja kn ko lt ml mr nl nn or pa pl pt pt_BR ru
	sk sr sr@latin sv ta te th tr uk zh_CN zh_TW )
inherit l10n-r1

src_unpack()
{
	gitlab:src_unpack
}

src_prepare:locales()
{
	local l locales dir='po' pre='' post='.po'

	l10n_find_changes_in_dir "${dir}" "${pre}" "${post}"

	l10n_get_locales locales app off
	for l in ${locales}
	do
		rrm "${dir}/${pre}${l}${post}"
		rsed -e "/^${l}$/d" -i -- "${dir}/LINGUAS"
	done
}

src_prepare() {
	xdg_src_prepare

	src_prepare:locales

	eautoreconf
}

src_configure()
{
	# lots of warnings when glib is updated more often
	append-cxxflags "-Wno-deprecated-declarations"

	local -a my_econf_args=(
		--disable-lynx	# Turn off lynx usage for plain-text documentation generation

		$(use_enable nls)
	)
	econf "${my_econf_args[@]}"
}
