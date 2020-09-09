# Copyright 2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit qmake-utils toolchain-funcs xdg-utils

DESCRIPTION="Powerful yet simple to use screenshot software"
HOMEPAGE="https://flameshot.js.org"
SRC_URI="https://github.com/lupoDharkael/${PN}/archive/v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="FreeArt GPL-3 Apache-2.0"
SLOT="0"
KEYWORDS="~amd64 ~arm ~arm64 ~x86"

IUSE="+dbus"

FS_LINGUAS="
	ca es fr hu ka pl ru tr zh_CN zh_TW
"

for lingua in ${FS_LINGUAS}; do
	IUSE="${IUSE} l10n_${lingua/_/-}"
done

DEPEND="
	>=dev-qt/qtcore-5.3.0:5
	dev-qt/qtgui:5
	dev-qt/qtsingleapplication[qt5(+),X]
	>=dev-qt/qtwidgets-5.3.0:5
	>=dev-qt/qtsvg-5.3.0:5
	>=dev-qt/qtnetwork-5.3.0:5
	dbus? (
		>=dev-qt/qtdbus-5.3.0:5
		sys-apps/dbus
	)
"
BDEPEND="
	>=dev-qt/linguist-tools-5.3.0:5
"
RDEPEND="${DEPEND}"
PATCHES=(
	"${FILESDIR}/${P}-unbundle-qtsingleapplication.patch"
	"${FILESDIR}/${P}-missing-include-fix.patch"
)
pkg_pretend(){
	if tc-is-gcc && ver_test "$(gcc-version)" -lt 4.9.2 ;then
		die "You need at least GCC 4.9.2 to build this package"
	fi
}

src_prepare(){
	sed -i "s|TAG_VERSION = .*|TAG_VERSION = v${PV}|" ${PN}.pro
	sed -i "s#icons#pixmaps#" ${PN}.pro
	sed -i "s#^Icon=.*#Icon=${PN}#" "docs/desktopEntry/package/${PN}.desktop" \
		"snap/gui/${PN}.desktop" \
		"snap/gui/${PN}-init.desktop"
	rm -r src/third-party/singleapplication || die
	default

	# QA check in case linguas are added or removed
	enum() {
		echo ${#}
	}

	[[ $(enum ${FS_LINGUAS}) -eq $(enum $(echo translations/*.ts)) ]] \
		|| die "Numbers of recorded and actual linguas do not match"
	unset enum

	# Remove localisations
	local lingua
	for lingua in ${FS_LINGUAS}; do
		if ! use l10n_${lingua/_/-}; then
			sed -i ${PN}.pro -e "/\.*Internationalization_${lingua}\.ts.*/d" || die
			rm translations/Internationalization_${lingua}.ts || die
		fi
	done
}

src_configure(){
	eqmake5 CONFIG+=packaging
}

src_install(){
	emake INSTALL_ROOT="${D}" install
}

pkg_postinst(){
	xdg_desktop_database_update
	xdg_icon_cache_update
	xdg_mimeinfo_database_update
}

pkg_postrm(){
	xdg_desktop_database_update
	xdg_icon_cache_update
	xdg_mimeinfo_database_update
}
