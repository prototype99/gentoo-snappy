# Copyright 2016-2017,2019 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2

EAPI=7
inherit rindeal

## git-hosting.eclass:
GH_RN='github:jpmens'

## EXPORT_FUNCTIONS: src_unpack
inherit git-hosting

## functions: eautoreconf
inherit autotools

DESCRIPTION='Web log analyzer using probabilistic data structures'
LICENSE='GPL-2'

SLOT='0'

KEYWORDS='~amd64 ~arm ~arm64'

src_prepare() {
	default

	eautoreconf
}
