# Copyright 2018-2019 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2

EAPI=7
inherit rindeal

## github.eclass:
GITHUB_NS="jarun"
GITHUB_REF="v${PV}"

##
inherit github

## functions: tc-export
inherit toolchain-funcs

## functions: newbashcomp
inherit bash-completion-r1

DESCRIPTION="The missing terminal file browser for X"
HOMEPAGE_A=(
	"${GITHUB_HOMEPAGE}"
)
LICENSE_A=(
	"BSD-2-Clause"
)

SLOT="0"

SRC_URI_A=(
	"${GITHUB_SRC_URI}"
)

KEYWORDS_A=(
	"~amd64"
	"~arm"
	"~arm64"
)
IUSE_A=(
	+unicode
	+readline
	+locale
)

CDEPEND_A=(
	"sys-libs/ncurses:0=[unicode?]"
	"readline? ( sys-libs/readline:0= )"
)
DEPEND_A=( "${CDEPEND_A[@]}"
	"virtual/pkgconfig:0"
)
RDEPEND_A=( "${CDEPEND_A[@]}" )

inherit arrays

src_unpack()
{
	github:src_unpack
}

src_prepare()
{
	# do build configuration with variables instead of targets
	# https://github.com/jarun/nnn/pull/344
	eapply "${FILESDIR}/344.patch"

	eapply_user
}

src_compile()
{
	tc-export CC
	tc-export PKG_CONFIG

	local -a emake_cmd=( emake
		CFLAGS_OPTIMIZATION=

		O_DEBUG=0
		O_NORL="$(usex readline 0 1)"
		O_NOLOC="$(usex locale 0 1)"
	)
	"${emake_cmd[@]}"
}

src_install()
{
	dobin "${PN}"
	doman "${PN}.1"

	# TODO: plugins
	# TODO: scripts

	einstalldocs

	## bash completion
	newbashcomp "misc/auto-completion/bash/nnn-completion.bash" "${PN}"

	## fish completion
	insinto "/usr/share/fish/vendor_completions.d"
	doins "misc/auto-completion/fish/${PN}.fish"

	## zsh completion
	insinto "/usr/share/zsh/site-functions"
	doins "misc/auto-completion/zsh/_${PN}"
}
