# Copyright 2018-2019 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2

EAPI=7
inherit rindeal

PAGURE_PROJ="mailcap"

## uses are self-explanatory
inherit pagure

DESCRIPTION="MIME type associations for file types"
HOMEPAGE="${PAGURE_HOMEPAGE}"
LICENSE="public-domain"

SLOT="0"
ref="ec8c60e"
SRC_URI="${PAGURE_HOMEPAGE}/raw/${ref}/f/mime.types"

KEYWORDS="amd64 arm arm64"

S="${WORKDIR}"

RESTRICT+=" mirror"

src_unpack() { : ; }
src_configure() { : ; }
src_compile() { : ; }
src_test() { : ; }

src_install() {
	insinto /etc
	doins "${DISTDIR}"/mime.types
}
