# Copyright 2016-2017,2019 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2

EAPI="7"
inherit rindeal

## github.eclass:
GITHUB_NS="lxqt"

##
inherit github

## EXPORT_FUNCTIONS:
inherit cmake-utils

DESCRIPTION="Pulseaudio mixer in Qt (port of pavucontrol)"
HOMEPAGE_A=(
	"${GITHUB_HOMEPAGE}"
)
LICENSE_A=(
	"GPL-2.0-or-later"
)

SLOT="0"

SRC_URI_A=(
	"${GITHUB_SRC_URI}"
)

KEYWORDS="~amd64"

IUSE_A=(
	nls
)

CDEPEND_A=(
	"dev-qt/qtwidgets:5"
	"dev-qt/qtdbus:5"

	">=dev-libs/glib-2.50.0:2"

	"media-sound/pulseaudio[glib]"
)
DEPEND_A=( "${CDEPEND_A[@]}"
	"nls? ( dev-qt/linguist-tools:5 )"

	">=dev-util/lxqt-build-tools-0.6.0"

	"virtual/pkgconfig"
	"x11-misc/xdg-user-dirs"
)
RDEPEND_A=( "${CDEPEND_A[@]}" )

inherit arrays

L10N_LOCALES=( as bn_IN ca cs cy da de el es fi fr gl gu he hi hu id it ja kn lt ml mr nb_NO nl or pa pl pt pt_BR ru sk
	sr sr@latin sv ta te th tr uk zh_CN zh_TW )
inherit l10n-r1

src_prepare:locales()
{
	local l locales dir="src/translations" pre="${PN}_" post=".ts"

	l10n_find_changes_in_dir "${dir}" "${pre}" "${post}"

	l10n_get_locales locales app $(usex nls off all)
	for l in ${locales}
	do
		rrm "${dir}/${pre}${l}${post}"
		rrm -f "${dir}/${pre}${l}.desktop"
	done
}

src_prepare()
{
	eapply_user

	src_prepare:locales

	cmake-utils_src_prepare
}

src_configure()
{
	local -a mycmakeargs=(
		# prevent lxqt-build-tools from pulling translations from a remote git server
		-D UPDATE_TRANSLATIONS=OFF
	)

	cmake-utils_src_configure
}
