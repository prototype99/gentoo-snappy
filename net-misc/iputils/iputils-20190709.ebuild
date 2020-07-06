# Copyright 1999-2017 Gentoo Foundation
# Copyright 2017-2019 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2

EAPI=7
inherit rindeal

## git-hosting.eclass:
GH_RN="github"
GH_REF="s${PV}"

## functions: dsf:eval
inherit dsf-utils

## functions: rindeal:prefix_flags
inherit rindeal-utils

## EXPORT_FUNCTIONS: src_unpack
inherit git-hosting

## functions: append-ldflags
inherit flag-o-matic

## EXPORT_FUNCTIONS: src_configure src_compile src_test src_install
inherit meson

## functions: fcaps
inherit fcaps

## functions: systemd_get_systemunitdir
inherit systemd

DESCRIPTION="Network monitoring tools including ping and ping6"
HOMEPAGE="https://wiki.linuxfoundation.org/networking/iputils ${GH_HOMEPAGE}"
LICENSE="BSD GPL-2+ rdisc"

SLOT="0"

KEYWORDS="~amd64 ~arm ~arm64"
IUSE_A=(
	html man
	caps idn ipv6 static nls

	+arping clockdiff +ping ninfod rarpd rdisc tftpd +tracepath traceroute6

	ninfod-messages rdisc-server

	crypto
	$(rindeal:prefix_flags \
		crypto_ \
			gcrypt nettle +openssl kernel)
)

LIB_DEPEND="
	caps? ( sys-libs/libcap[static-libs(+)] )
	idn? ( net-dns/libidn2:0[static-libs(+)] )
	ipv6? (
		crypto? (
			crypto_gcrypt?  ( dev-libs/libgcrypt:0=[static-libs(+)] )
			crypto_nettle?  ( dev-libs/nettle[static-libs(+)] )
			crypto_openssl? ( dev-libs/openssl:0[static-libs(+)] )
		)
	)
	nls? ( sys-devel/gettext[static-libs(+)] )
"
CDEPEND_A=(
	"!static? ( ${LIB_DEPEND//\[static-libs(+)]} )"
)
DEPEND_A=( "${CDEPEND_A[@]}"
	"static? ( ${LIB_DEPEND} )"
	"crypto_kernel? ( virtual/os-headers )"
	# xsltproc
	"$(dsf:eval \
		'html | man' \
			"dev-libs/libxslt
			app-text/docbook-xsl-ns-stylesheets" )"
)
RDEPEND_A=( "${CDEPEND_A[@]}"
	"arping?      ( !net-misc/arping )"
	"rarpd?       ( !net-misc/rarpd )"
	"traceroute6? ( !net-analyzer/traceroute )"
)

REQUIRED_USE_A=(
	"ipv6? ("
		"crypto? ("
			"^^ ("
					"$(rindeal:prefix_flags \
						crypto_ \
							gcrypt nettle openssl kernel)"
			")"
		")"
	")"
	"traceroute6? ( ipv6 )"
	"ninfod? ( crypto )"
)

inherit arrays

src_prepare() {
	eapply_user

	# put html files into correct dir
	rsed -e "s@get_option('datadir'), meson.project_name()@get_option('datadir'), 'doc/${PF}/html'@" -i -- doc/meson.build
}

src_configure() {
	use static && append-ldflags -static

	local emesonargs=(
		$(meson_use caps USE_CAP)
		$(meson_use idn USE_IDN)
		$(meson_use arping BUILD_ARPING)
		$(meson_use clockdiff BUILD_CLOCKDIFF)
		$(meson_use ping BUILD_PING)
		$(meson_use rarpd BUILD_RARPD)
		$(meson_use rdisc BUILD_RDISC)
		$(meson_use rdisc-server ENABLE_RDISC_SERVER)
		$(meson_use tftpd BUILD_TFTPD)
		$(meson_use tracepath BUILD_TRACEPATH)
		$(meson_use traceroute6 BUILD_TRACEROUTE6)
		$(meson_use ninfod BUILD_NINFOD)
		$(meson_use ninfod-messages NINFOD_MESSAGES)
		$(meson_use man BUILD_MANS)
		$(meson_use html BUILD_HTML_MANS)
		-D NO_SETCAP_OR_SUID=true  # we handle this manually using fcaps()
# 		$(meson_use ARPING_DEFAULT_DEVICE caps)  # TODO: string variable option
		# meson build doesn't have a default value set, so the systemd unit files
		# wouldn't be installed if systemd wasn't found, thus set the value here
		-Dsystemdunitdir="$(systemd_get_systemunitdir)"
		$(meson_use nls USE_GETTEXT)
	)

	if use ipv6 && use crypto
	then
		emesonargs+=(
			-D USE_CRYPTO="$(usex crypto_gcrypt gcrypt $(usex crypto_nettle nettle $(usex crypto_openssl openssl $(usex crypto_kernel kernel ERROR))))"
		)
	else
		emesonargs+=(
			-D USE_CRYPTO="none"
		)
	fi

	meson_src_configure
}

src_install() {
	meson_src_install

	if use arping || use ping
	then
		dodir /bin
		local f
		for f in $(usex arping arping '') $(usex ping{,} '')
		do
			rmv "${ED%/}"/usr/bin/${f} "${ED%/}"/bin/
		done
	fi
}

pkg_postinst() {
	local cap_bins=(
		$(usex ping 'bin/ping' '')
		$(usex arping 'bin/arping' '')
		$(usex clockdiff 'usr/bin/clockdiff' '')
		$(usex traceroute6 'usr/bin/traceroute6' '')
	)

	(( ${#cap_bins[*]} )) && fcaps cap_net_raw+p "${cap_bins[@]}"
}
