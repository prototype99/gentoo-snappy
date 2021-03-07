# Copyright 1999-2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

PYTHON_COMPAT=( py{thon3_{7,8},py3} )
inherit cmake flag-o-matic xdg toolchain-funcs python-single-r1

DESCRIPTION="SVG based generic vector-drawing program"
HOMEPAGE="https://inkscape.org/"
SRC_URI="https://inkscape.org/gallery/item/21571/${P}.tar.xz"

LICENSE="GPL-2 LGPL-2.1"
SLOT="0"
KEYWORDS="~amd64 ~arm ~arm64 ~hppa ~ia64 ~ppc ~ppc64 ~s390 ~sparc ~x86"
IUSE="cdr dbus dia exif glibmm-new +glibmm-old graphicsmagick imagemagick inkjar jemalloc jpeg latex lcms
nls openmp postscript spell static-libs svg2 visio wpg"

REQUIRED_USE="${PYTHON_REQUIRED_USE}
	^^ ( glibmm-old glibmm-new )
	graphicsmagick? ( imagemagick )"

PATCHES=(
	"${FILESDIR}/missing_atomic_include.patch"
)

BDEPEND="
	dev-util/glib-utils
	>=dev-util/intltool-0.40
	>=sys-devel/gettext-0.17
	virtual/pkgconfig
"
COMMON_DEPEND="${PYTHON_DEPS}
	|| ( dev-lang/python:=[xml] dev-python/pypy3 )
	>=app-text/poppler-0.57.0:=[cairo]
	>=dev-cpp/cairomm-1.12
	glibmm-old? ( <dev-cpp/glibmm-2.64 )
	glibmm-new? ( >=dev-cpp/glibmm-2.65.2 )
	dev-cpp/gtkmm:3.0
	>=dev-cpp/pangomm-2.40
	>=dev-libs/boehm-gc-7.2:=
	dev-libs/double-conversion:=
	>=dev-libs/glib-2.48
	>=dev-libs/libsigc++-2.8
	>=dev-libs/libxml2-2.7.4
	>=dev-libs/libxslt-1.1.25
	>=dev-libs/gdl-3.4:3
	dev-libs/popt
	media-gfx/potrace
	media-libs/fontconfig
	media-libs/freetype:2
	media-libs/libpng:0=
	net-libs/libsoup
	sci-libs/gsl:=
	>=x11-libs/cairo-1.14
	x11-libs/libX11
	>=x11-libs/pango-1.37.2
	>=x11-libs/gtk+-3.22:3
	$(python_gen_cond_dep '
		dev-python/lxml[${PYTHON_MULTI_USEDEP}]
		media-gfx/scour[${PYTHON_MULTI_USEDEP}]
	')
	cdr? (
		app-text/libwpg:0.3
		dev-libs/librevenge
		media-libs/libcdr
	)
	dbus? ( dev-libs/dbus-glib )
	exif? ( media-libs/libexif )
	imagemagick? (
		!graphicsmagick? ( <media-gfx/imagemagick-7:=[cxx] )
		graphicsmagick? ( media-gfx/graphicsmagick:=[cxx] )
	)
	jemalloc? ( dev-libs/jemalloc )
	jpeg? ( virtual/jpeg:0 )
	lcms? ( >=media-libs/lcms-2.2:2 )
	spell? (
		app-text/aspell
		app-text/gtkspell:3
	)
	visio? (
		app-text/libwpg:0.3
		dev-libs/librevenge
		media-libs/libvisio
	)
	wpg? (
		app-text/libwpg:0.3
		dev-libs/librevenge
	)
"
# These only use executables provided by these packages
# See share/extensions for more details. inkscape can tell you to
# install these so we could of course just not depend on those and rely
# on that.
RDEPEND="${COMMON_DEPEND}
	$(python_gen_cond_dep '
		dev-python/numpy[${PYTHON_MULTI_USEDEP}]
	')
	dia? ( app-office/dia )
	latex? (
		media-gfx/pstoedit[plotutils]
		app-text/dvipsk
		app-text/texlive-core
	)
	postscript? ( app-text/ghostscript-gpl )
"
DEPEND="${COMMON_DEPEND}
	>=dev-libs/boost-1.65
"

RESTRICT="test"

S="${WORKDIR}"/${P}_2020-09-07_3bc2e813f5

pkg_pretend() {
	if [[ ${MERGE_TYPE} != binary ]] && use openmp; then
		tc-has-openmp || die "Please switch to an openmp compatible compiler"
	fi
}

src_prepare() {
	cmake_src_prepare
	sed -i "/install.*COPYING/d" CMakeScripts/ConfigCPack.cmake || die
}

src_configure() {
	# aliasing unsafe wrt #310393
	append-flags -fno-strict-aliasing

	local mycmakeargs=(
		# -DWITH_LPETOOL   # Compile with LPE Tool and experimental LPEs enabled
		-DENABLE_POPPLER=ON
		-DWITH_NLS=$(usex nls)
		-DENABLE_POPPLER_CAIRO=ON
		-DWITH_PROFILING=OFF
		-DWITH_LIBCDR=$(usex cdr)
		-DWITH_DBUS=$(usex dbus)
		-DWITH_IMAGE_MAGICK=$(usex imagemagick $(usex !graphicsmagick))
		-DWITH_GRAPHICS_MAGICK=$(usex graphicsmagick $(usex imagemagick)) # both must be enabled to use GraphicsMagick
		-DWITH_JEMALLOC=$(usex jemalloc)
		-DENABLE_LCMS=$(usex lcms)
		-DWITH_OPENMP=$(usex openmp)
		-DBUILD_SHARED_LIBS=$(usex !static-libs)
		-DWITH_SVG2=$(usex svg2)
		-DWITH_LIBVISIO=$(usex visio)
		-DWITH_LIBWPG=$(usex wpg)
	)

	cmake_src_configure
}

src_install() {
	cmake_src_install

	find "${ED}" -type f -name "*.la" -delete || die

	find "${ED}"/usr/share/man -type f -maxdepth 3 -name '*.bz2' -exec bzip2 -d {} \; || die

	find "${ED}"/usr/share/man -type f -maxdepth 3 -name '*.gz' -exec gzip -d {} \; || die

	local extdir="${ED}"/usr/share/${PN}/extensions

	if [[ -e "${extdir}" ]] && [[ -n $(find "${extdir}" -mindepth 1) ]]; then
		python_optimize "${ED}"/usr/share/${PN}/extensions
	fi
}