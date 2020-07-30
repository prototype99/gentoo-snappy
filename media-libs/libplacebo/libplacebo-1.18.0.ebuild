# Copyright 2018-2019 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2

EAPI=7
inherit rindeal

## git-hosting.eclass:
GH_RN="github:haasn"
GH_REF="v${PV}"

## EXPORT_FUNCTIONS: src_unpack
inherit git-hosting

## EXPORT_FUNCTIONS: src_configure src_compile src_test src_install
## functions: meson_use
inherit meson

DESCRIPTION="Reusable library for GPU-accelerated video/image rendering primitives"
LICENSE="LGPL-2.1+"

SLOT="0"

KEYWORDS="~amd64 ~arm ~arm64"
IUSE_A=( vulkan test bench )

CDEPEND_A=(
# 	"vulkan? ( media-libs/vulkan-sdk )" ## TODO
)
DEPEND_A=( "${CDEPEND_A[@]}" )
RDEPEND_A=( "${CDEPEND_A[@]}" )

REQUIRED_USE_A=(  )
RESTRICT+=""

inherit arrays

src_configure() {
	local emesonargs=(
# 		$(meson_use vulkan) ## TODO
		-D shaderc=no # https://github.com/google/shaderc/releases is still beta
		$(meson_use test tests)
		$(meson_use bench)
	)
	meson_src_configure
}
