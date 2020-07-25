# Copyright 2016-2017,2019 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2

EAPI=7
inherit rindeal

## git-hosting.eclass:
GH_RN='github:fcambus'

## EXPORT_FUNCTIONS: src_unpack
## variables: GH_HOMEPAGE
inherit git-hosting

DESCRIPTION='Weather in your terminal, with ANSI colors and Unicode symbols'
HOMEPAGE="${GH_HOMEPAGE}"
LICENSE='BSD'

SLOT='0'

KEYWORDS='~amd64 ~arm ~arm64'
IUSE_A=( )

CDEPEND_A=(
	"media-libs/gd:*"
)
DEPEND_A=( "${CDEPEND_A[@]}" )
RDEPEND_A=( "${CDEPEND_A[@]}"
	"app-misc/jq:0"
	"|| ("
		"net-misc/wget:0"
		"net-misc/curl:0"
	")"
	"sys-devel/bc:0"
)

inherit arrays

src_install() {
	dobin "${PN}"

	doman "${PN}.1"

	einstalldocs
	dodoc 'ansiweatherrc.example'

	insinto /usr/share/zsh/site-functions
	newins ansiweather.plugin.zsh -ansiweather
}
