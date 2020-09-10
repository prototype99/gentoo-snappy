# Copyright 2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit cmake

DESCRIPTION="Tool for annotating images"
MY_PN=kImageAnnotator
HOMEPAGE="https://github.com/ksnip/${MY_PN}/"
MY_P="${MY_PN}-${PV}"
SRC_URI="${HOMEPAGE}archive/v${PV}.tar.gz -> ${MY_P}.tar.gz"

LICENSE="LGPL-3"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="test"

RESTRICT="!test? ( test )"

QV="-5.9.4:5"
RDEPEND=">=dev-qt/qtwidgets${QV}
	>=dev-qt/qtsvg${QV}
	>=x11-libs/kcolorpicker-0.1.4"
DEPEND="${RDEPEND}
	test? ( >=dev-qt/qttest${QV} )"
BDEPEND=">=dev-util/cmake-3.5"

S="${WORKDIR}/${MY_P}"

src_configure() {
	local mycmakeargs=(
		-DBUILD_SHARED_LIBS=ON
	)

	use test && mycmakeargs+=( -DBUILD_TESTS=ON )

	cmake_src_configure
}