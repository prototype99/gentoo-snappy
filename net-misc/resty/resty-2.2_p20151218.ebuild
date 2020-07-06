# Copyright 2016-2017 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2

EAPI=6
inherit rindeal

GH_RN='github:micha'
[[ "${PV}" == *9999* ]] || \
	GH_REF="82d9cbd2776acd3f4c103d5fe00c74232648fee3"

inherit git-hosting

DESCRIPTION='Little command line REST client that you can use in pipelines (bash or zsh)'
LICENSE='MIT'

SLOT='0'

[[ "${PV}" == *9999* ]] || \
	KEYWORDS='~amd64 ~arm ~arm64'

# opt: lynx/html2text for pretty printing

src_install() {
	insinto "/usr/share/${PN}"
	doins "${PN}"

	local DOCS=( CHANGES.md README.md )
	einstalldocs
}
