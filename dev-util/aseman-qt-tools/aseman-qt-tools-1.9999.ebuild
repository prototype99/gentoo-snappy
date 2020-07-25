# Copyright 2016 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2

EAPI=6
inherit rindeal

GH_RN="github:Aseman-Land"
# GH_REF="v${PV}-stable" # use only stable versions

inherit git-hosting
inherit qmake-utils

DESCRIPTION="Set of tools to support cross platform Qt projects by Aseman"
LICENSE="GPL-3"

SLOT="0"

[[ "${PV}" == *9999* ]] || KEYWORDS="~amd64"
IUSE_A=( +keychain sensors +widgets +multimedia webkitwidgets webenginewidgets +positioning +dbus )

CDEPEND_A=(
	"dev-qt/qtcore:5"
	"dev-qt/qtgui:5"
	"dev-qt/qtnetwork:5"
	"dev-qt/qtwidgets:5"
	"dev-qt/qtdeclarative:5" # QtQuick, QML

	"dbus?			( dev-qt/qtdbus:5 )"
	"keychain?		( dev-libs/qtkeychain )"
	"multimedia?	( dev-qt/qtmultimedia:5 )"
	"positioning?	( dev-qt/qtpositioning:5 )"
	"sensors?		( dev-qt/qtsensors:5 )"
	"webenginewidgets?	( dev-qt/qtwebengine:5 )"
	"webkitwidgets?	( dev-qt/qtwebkit:5 )"
)
DEPEND_A=( "${CDEPEND_A[@]}"
	"virtual/pkgconfig"
)
RDEPEND_A=( "${CDEPEND_A[@]}" )

inherit arrays

BUILD_DIR="${WORKDIR}/build"

src_prepare() {
	default

	rmkdir "${BUILD_DIR}"
}

src_configure() {
	cd "${BUILD_DIR}" || die

	local args=(
		# NOTE: do not set PREFIX, it overrides QT_INSTALL_QML

		# asemantools.pri
		"DEFINES+=$(usex keychain '' 'DISABLE_KEYCHAIN')" # -lqt5keychain
		"QT+=$(usev sensors)"
		"QT+=$(usev widgets)"
		"QT+=$(usev multimedia)"
		"QT+=$(usev webkitwidgets)"
		"QT+=$(usev webenginewidgets)"
		"QT+=$(usev positioning)"
		"QT+=$(usev dbus)" # notifications
	)

	eqmake5 "${args[@]}" "${S}/asemantools.pro"
}

src_compile() {
	cd "${BUILD_DIR}" || die

	default
}

src_install() {
	cd "${BUILD_DIR}" || die

	emake INSTALL_ROOT="${ED}" install

	cd "${S}" || die

	einstalldocs
}
