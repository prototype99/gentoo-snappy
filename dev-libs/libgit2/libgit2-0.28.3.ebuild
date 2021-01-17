# Copyright 1999-2018 Gentoo Foundation
# Copyright 2018-2019 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2

EAPI=7
inherit rindeal

## github.eclass:
GITHUB_REF="v${PV}"

## functions: dsf:eval
inherit dsf-utils

## functions: rindeal:prefix_flags
inherit rindeal-utils

## functions: github:src_unpack
## variables: GITHUB_HOMEPAGE, GITHUB_SRC_URI
inherit github

## EXPORT_FUNCTIONS: src_prepare src_configure src_compile src_test src_install
inherit cmake-utils

DESCRIPTION="Linkable library implementation of Git"
HOMEPAGE_A=(
	"https://libgit2.org/"
	"${GITHUB_HOMEPAGE}"
)
LICENSE="GPL-2-with-linking-exception"

SLOT="0/$(ver_cut 2)"

SRC_URI_A=(
	"${GITHUB_SRC_URI}"
)

KEYWORDS="~amd64 ~arm ~arm64"
IUSE_A=( debug gssapi +ssh test +threads trace +https
	"$(rindeal:prefix_flags \
		sha1_ \
			generic +openssl mbedtls collision_detection)"
	"$(rindeal:prefix_flags \
		https_ \
			+openssl mbedtls)"
)

CDEPEND_A=(
	"$(dsf:eval \
		'sha1_openssl | https_openssl' \
			"dev-libs/openssl:0=")"
	"$(dsf:eval \
		'sha1_mbedtls | https_mbedtls' \
			"net-libs/mbedtls:0=")"
	"sys-libs/zlib"
	"=net-libs/http-parser-2*:="
	"gssapi? ( virtual/krb5 )"
	"ssh? ( net-libs/libssh2 )"
)
DEPEND_A=( "${CDEPEND_A[@]}"
	"virtual/pkgconfig"
)
RDEPEND_A=( "${CDEPEND_A[@]}" )

REQUIRED_USE_A=(
	"^^ ( $(rindeal:prefix_flags \
		sha1_ \
			generic openssl mbedtls collision_detection) )"
	"https? ( ^^ ( $(rindeal:prefix_flags \
		https_ \
			openssl mbedtls) ) )"
)
RESTRICT+=" test"

inherit arrays

src_unpack() {
	github:src_unpack
}

src_configure() {
	local mycmakeargs=(
		-D LIB_INSTALL_DIR="${EPREFIX}/usr/$(get_libdir)"

		-D SONAME=ON
		-D BUILD_SHARED_LIBS=ON  # OFF for static
		-D THREADSAFE=$(usex threads)
		-D BUILD_CLAR=$(usex test)
		-D BUILD_EXAMPLES=OFF
		-D BUILD_FUZZERS=OFF
		-D TAGS=OFF  # ctags
		-D PROFILE=OFF
		-D ENABLE_TRACE=$(usex trace)
		-D LIBGIT2_FILENAME=OFF
		-D SHA1_BACKEND=$(usex sha1_generic "Generic" $(usex sha1_openssl "OpenSSL" $(usex sha1_mbedtls "mbedTLS" $(usex sha1_collision_detection "CollisionDetection" "die"))))
		-D USE_SSH=$(usex ssh)
		-D USE_HTTPS=$(usex https_openssl "OpenSSL" $(usex https_mbedtls "mbedTLS"))
		-D USE_GSSAPI=$(usex gssapi)
		-D USE_STANDALONE_FUZZERS=OFF
		-D VALGRIND=$(usex debug)
		-D USE_EXT_HTTP_PARSER=ON
		-D DEBUG_POOL=$(usex debug)
		-D ENABLE_WERROR=OFF
		-D USE_BUNDLED_ZLIB=OFF
		-D DEPRECATE_HARD=OFF
		-D ENABLE_REPRODUCIBLE_BUILDS=OFF
	)
	cmake-utils_src_configure
}

src_install() {
	DOCS=( AUTHORS README.md )

	cmake-utils_src_install
}
