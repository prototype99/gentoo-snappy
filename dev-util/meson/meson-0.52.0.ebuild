# Copyright 2019 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2

EAPI=7
inherit rindeal

## github.eclass:
GITHUB_NS="mesonbuild"

## python-r1.eclass:
PYTHON_COMPAT=( python3_{5,6,7} )

## usage is self-explanatory
inherit github

## EXPORT_FUNCTIONS: src_prepare src_configure src_compile src_test src_install
inherit distutils-r1

## functions: dobashcomp
inherit bash-completion-r1

DESCRIPTION="Meson Build System"
HOMEPAGE_A=(
	"https://mesonbuild.com/"
	"${GITHUB_HOMEPAGE}"
)
LICENSE_A=(
	"Apache-2.0"
)

SLOT="0"

SRC_URI_A=(
	"${GITHUB_SRC_URI}"
)

unstable="~"
KEYWORDS_A=(
	"${unstable}amd64"
	"${unstable}arm"
	"${unstable}arm64"
)
IUSE_A=(
)

CDEPEND_A=( )
DEPEND_A=( "${CDEPEND_A[@]}"
	"dev-python/setuptools[${PYTHON_USEDEP}]"
)
RDEPEND_A=( "${CDEPEND_A[@]}"
	"dev-util/ninja:*"
)

inherit arrays

src_unpack() {
	github:src_unpack
}

python_prepare_all() {
	eapply_user

	rsed -e "s|data_files=data_files,||" -i -- setup.py

	distutils-r1_python_prepare_all
}

python_install_all() {
	distutils-r1_python_install_all

	doman "man/meson.1"

	dobashcomp "data/shell-completions/bash/${PN}"

	insinto "/usr/share/zsh/site-functions"
	doins "data/shell-completions/zsh/_meson"

	local -A vim_plugins
	local -- f
	for f in data/syntax-highlighting/vim/*/*.vim
	do
		vim_plugins["$(dirname "${f}")"]=
	done
	insinto /usr/share/vim/vimfiles
	doins -r "${!vim_plugins[@]}"
}
