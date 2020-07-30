# Copyright 1999-2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

DESCRIPTION="Provides /etc/mime.types file"
HOMEPAGE="https://pagure.io/fork/petabyteboy/mailcap/"
SRC_URI="${HOMEPAGE}raw/d2ea7b5ed6dc8e35064d384775ceb89396eabf0a/f/mime.types"

LICENSE="public-domain"
SLOT="0"
KEYWORDS="amd64 arm arm64"

S="${WORKDIR}"

src_install() {
	insinto /etc
	doins "${DISTDIR}"/mime.types
}
