# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit cmake-utils pax-utils systemd user

DESCRIPTION="Rapid spam filtering system"
HOMEPAGE="https://rspamd.com"
SRC_URI="https://github.com/vstakhov/rspamd/archive/${PV}.tar.gz -> ${P}.tar.gz"
RESTRICT="mirror"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="cpu_flags_x86_ssse3 fann gd jemalloc +jit libressl pcre2 +torch"
REQUIRED_USE="torch? ( jit )"

DEPEND="dev-db/sqlite:3
	dev-libs/glib:2
	dev-libs/icu
	dev-libs/libevent
	<dev-util/ragel-7.0
	sys-apps/file
	cpu_flags_x86_ssse3? ( dev-libs/hyperscan )
	elibc_glibc? ( net-libs/libnsl:0= )
	fann? ( sci-mathematics/fann )
	gd? ( media-libs/gd[jpeg] )
	jemalloc? ( dev-libs/jemalloc )
	jit? ( dev-lang/luajit:2 )
	!libressl? ( dev-libs/openssl:0=[-bindist] )
	libressl? ( dev-libs/libressl:0= )
	!pcre2? ( dev-libs/libpcre[jit=] )
	pcre2? ( dev-libs/libpcre2[jit=] )"
RDEPEND="${DEPEND}"

QA_MULTILIB_PATHS="usr/lib/rspamd/.*"

pkg_setup() {
	enewgroup rspamd
	enewuser rspamd -1 -1 /var/lib/rspamd rspamd
}

src_configure() {
	# shellcheck disable=SC2191,SC2207
	local mycmakeargs=(
		-DCONFDIR=/etc/rspamd
		-DRUNDIR=/var/run/rspamd
		-DDBDIR=/var/lib/rspamd
		-DLOGDIR=/var/log/rspamd
		-DENABLE_LUAJIT=$(usex jit ON OFF)
		-DENABLE_FANN=$(usex fann ON OFF)
		-DENABLE_GD=$(usex gd ON OFF)
		-DENABLE_PCRE2=$(usex pcre2 ON OFF)
		-DENABLE_JEMALLOC=$(usex jemalloc ON OFF)
		-DENABLE_HYPERSCAN=$(usex cpu_flags_x86_ssse3 ON OFF)
		-DENABLE_TORCH=$(usex torch ON OFF)
	)
	cmake-utils_src_configure
}

src_install() {
	cmake-utils_src_install

	newinitd "${FILESDIR}"/rspamd.initd-r1 rspamd
	systemd_dounit rspamd.service

	# Remove mprotect for JIT support
	if use jit; then
		pax-mark m "${ED%/}"/usr/bin/rspamd-* \
			"${ED%/}"/usr/bin/rspamadm-* || die
	fi

	insinto /etc/logrotate.d
	newins "${FILESDIR}"/rspamd.logrotate-r1 rspamd

	diropts -o rspamd -g rspamd
	keepdir /var/{lib,log}/rspamd
}
