# Copyright 2016 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2

EAPI=6
inherit rindeal

GH_RN="github:Aseman-Land:libqtelegram-aseman-edition"
# GH_REF="v${PV}-stable" # use only stable versions
EGIT_SUBMODULES=()

inherit git-hosting
inherit qmake-utils

DESCRIPTION="Fork of libqtelegram by Aseman Team with support for Windows and MacOSX"
LICENSE="GPL-3"

SLOT="0"

[[ "${PV}" == *9999* ]] || KEYWORDS="~amd64"

CDEPEND_A=(
	"dev-qt/qtgui:5"
	"dev-qt/qtnetwork:5"
	"dev-qt/qtmultimedia:5"
)
DEPEND_A=( "${CDEPEND_A[@]}"
	"dev-util/libqtelegram-generator"
	"virtual/pkgconfig"
)
RDEPEND_A=( "${CDEPEND_A[@]}" )

inherit arrays

BUILD_DIR="${WORKDIR}/build"

src_prepare() {
	default

	sed -e "/LIBS *+=.*-lssl/ s|-lssl -lcrypto -lz|$(pkg-config --libs-only-l openssl zlib)|" \
		-i -- "${PN,,}.pri" || die

	mkdir -p "${BUILD_DIR}" >/dev/null || die
}

src_configure() {
	cd "${BUILD_DIR}" || die

	einfo "Generating Telegram API code from schemes ..."
	# check `./init` script for an updated command
	"${EROOT}/usr/libexec/libqtelegram-generator" \
		57 "${S}/scheme/scheme-57.tl" "${S}" || die

	local myqmake5args=(
		# install headers in `telegram/objects` dir, which is required for TelegramQML
		CONFIG+=typeobjects

		OPENSSL_LIB_DIR="$(pkg-config --libs-only-L openssl)"
		OPENSSL_INCLUDE_PATH="$(pkg-config --cflags-only-I openssl)"
	)

	eqmake5 "${myqmake5args[@]}" "${S}/${PN}.pro"
}

src_install() {
	cd "${BUILD_DIR}" || die

	emake INSTALL_ROOT="${ED}" install

	cd "${S}" || die

	einstalldocs
}
