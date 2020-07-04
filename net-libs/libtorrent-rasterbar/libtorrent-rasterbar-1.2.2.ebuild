# Copyright 2016-2019 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2

EAPI=7
inherit rindeal

LT_SONAME='10'

## EXPORT_FUNCTIONS: src_unpack src_prepare src_configure src_compile src_install
inherit libtorrent-rasterbar

KEYWORDS="~amd64 ~arm ~arm64"
