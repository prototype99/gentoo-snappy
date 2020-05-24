# Copyright 1999-2020 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=7

VALA_MIN_API_VERSION=0.40

inherit gnome2-utils meson vala xdg-utils

DESCRIPTION="A simple, powerful, sexy file manager for the Pantheon desktop"
HOMEPAGE="https://github.com/elementary/files"
SRC_URI="https://github.com/elementary/files/archive/${PV}.tar.gz -> ${P}.tar.gz"
KEYWORDS="amd64"

LICENSE="GPL-3"
SLOT="0"
IUSE="gvfs img-dim-hover-list l10n_ar l10n_ca l10n_cs l10n_da l10n_es l10n_fr l10n_he l10n_ja l10n_nl l10n_pt l10n_pt-BR l10n_ru l10n_tr l10n_zh-CN mod-date-prop nls unity zeitgeist"

DEPEND="
	$(vala_depend)
	>=dev-util/meson-0.50.0
	nls? ( sys-devel/gettext )
	unity? (
		>=unity-base/unity-4.0.0
		>=x11-misc/plank-0.10.9
	)
	zeitgeist? ( >=gnome-extra/zeitgeist-1.0.2 )
	virtual/pkgconfig
"
RDEPEND="${DEPEND}
	dev-db/sqlite:3
	dev-libs/dbus-glib
	>=dev-libs/glib-2.40.0:2
	>=dev-libs/granite-5.3.0
	dev-libs/libgee:0.8
	dev-libs/libgit2-glib
	dev-libs/libcloudproviders[vala]
	gvfs? ( gnome-base/gvfs )
	>=media-libs/libcanberra-0.30
	>=x11-libs/gtk+-3.22:3
	>=x11-libs/libnotify-0.7.2
	>=x11-libs/pango-1.1.2
	>=xfce-extra/tumbler-0.2.1
"

PATCHES=(
	"${FILESDIR}"/cleanup.patch
	"${FILESDIR}"/fix-hitbox.patch
	"${FILESDIR}"/new-flags.patch
	"${FILESDIR}"/search-align.patch
)

S="${WORKDIR}/files-${PV}"

src_prepare() {
	use img-dim-hover-list && eapply "${FILESDIR}"/hover.patch
	use l10n_ar && eapply "${FILESDIR}"/ar.patch
	use l10n_cs && eapply "${FILESDIR}"/cs.patch
	use l10n_da && eapply "${FILESDIR}"/da.patch
	use l10n_es && eapply "${FILESDIR}"/es.patch
	use l10n_fr && eapply "${FILESDIR}"/fr.patch
	use l10n_he && eapply "${FILESDIR}"/he.patch
	use l10n_ja && eapply "${FILESDIR}"/ja.patch
	use l10n_nl && eapply "${FILESDIR}"/nl.patch
	use l10n_pt && eapply "${FILESDIR}"/pt.patch
	use l10n_pt-BR && eapply "${FILESDIR}"/pt-BR.patch
	use l10n_ru && eapply "${FILESDIR}"/ru.patch
	use l10n_tr && eapply "${FILESDIR}"/tr.patch
	use l10n_zh-CN && eapply "${FILESDIR}"/zh-CN.patch
	use mod-date-prop && eapply "${FILESDIR}"/modified.patch
	default
	vala_src_prepare
}

src_configure() {
	local emesonargs=(
		$(meson_feature unity with-unity)
		$(meson_feature zeitgeist with-zeitgeist)
	)
	meson_src_configure
}

pkg_preinst() {
	gnome2_schemas_savelist
}

pkg_postinst() {
	gnome2_schemas_update
	xdg_icon_cache_update
	xdg_desktop_database_update
}

pkg_postrm() {
	gnome2_schemas_update
	xdg_icon_cache_update
	xdg_desktop_database_update
}
