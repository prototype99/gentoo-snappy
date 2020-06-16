# Copyright 1999-2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

PYTHON_COMPAT=( python3_{5..7} )

inherit font python-any-r1

DESCRIPTION="A Helvetica/Times/Courier/Arial replacement TrueType font, courtesy of Red Hat"
HOMEPAGE="https://github.com/liberationfonts/${PN}"
SRC_URI="!fontforge? ( ${HOMEPAGE}/files/4743886/${PN}-ttf-${PV}.tar.gz )
fontforge? ( ${HOMEPAGE}/files/4743885/${P}.tar.gz )"

KEYWORDS="~alpha amd64 arm arm64 ~ia64 ppc ppc64 x86 ~x64-cygwin ~amd64-linux ~x86-linux ~x64-solaris"
SLOT="0"
LICENSE="OFL-1.1"
IUSE="fontforge vanilla X"

FONT_SUFFIX="ttf"

FONT_CONF=(
	"${FILESDIR}/60-liberation-arial.conf"
	"${FILESDIR}/60-liberation-courier.conf"
	"${FILESDIR}/60-liberation-helvetica.conf"
	"${FILESDIR}/60-liberation-times.conf"
)

BDEPEND="
	fontforge? (
		${PYTHON_DEPS}
		media-gfx/fontforge
		$(python_gen_any_dep 'dev-python/fonttools[${PYTHON_USEDEP}]')
	)"

python_check_deps() {
	has_version -b "dev-python/fonttools[${PYTHON_USEDEP}]"
}
src_prepare() {
	if use fontforge; then
		use !vanilla && eapply "${FILESDIR}"/glyph.patch
		sed -i "s/= python3/= ${EPYTHON}/" Makefile || die
	fi
	default
}

pkg_setup() {
	if use fontforge; then
		FONT_S="${S}/${PN}-ttf-${PV}"
		python-any-r1_pkg_setup
	else
		FONT_S="${WORKDIR}/${PN}-ttf-${PV}"
		S="${FONT_S}"
	fi
	font_pkg_setup
}