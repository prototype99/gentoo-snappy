# Copyright 2012-2016 Gentoo Foundation
# Copyright 2016-2017,2019 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2

EAPI=7
inherit rindeal

PYTHON_COMPAT=( python3_{5,6,7} )

## gitlab.eclass:
GITLAB_SVR="https://0xacab.org"
GITLAB_NS="jvoisin"

##
inherit gitlab

## EXPORT: src_prepare, src_configure, src_compile, src_test, src_install
inherit distutils-r1

## EXPORT: src_prepare, pkg_preinst, pkg_postinst, pkg_postrm
inherit xdg

## functions: doicon
inherit desktop

DESCRIPTION="Metadata Anonymisation Toolkit"
HOMEPAGE_A=(
	"${GITLAB_HOMEPAGE}"
)
LICENSE="GPL-2"

SLOT="0"
SRC_URI_A=(
	"${GITLAB_SRC_URI}"
)

KEYWORDS="~amd64 ~arm ~arm64"
IUSE_A=(
	audio +image video +exif pdf sandbox
# 	nautilus  # probably not worth implementing
)

CDEPEND_A=(
	"${PYTHON_DEPS}"
)
DEPEND_A=( "${CDEPEND_A[@]}" )
RDEPEND_A=( "${CDEPEND_A[@]}"
	"audio? ( media-libs/mutagen[${PYTHON_USEDEP}] )"
	"exif? ( media-libs/exiftool:* )"
	"image? ("
		"dev-python/pycairo[${PYTHON_USEDEP}]"

		"dev-python/pygobject[${PYTHON_USEDEP}]"
		"x11-libs/gdk-pixbuf:2[introspection,jpeg,tiff]"
		"gnome-base/librsvg:2[introspection]"
	")"
	"video? ( media-video/ffmpeg:* )"
	"pdf? ("
		"dev-python/pycairo[${PYTHON_USEDEP}]"
		"dev-python/pygobject[${PYTHON_USEDEP}]"
		"app-text/poppler[introspection]"
	")"

# 	"nautilus? ( dev-python/nautilus-python[${PYTHON_USEDEP}] )"
	"sandbox? ( sys-apps/bubblewrap:* )"
)

REQUIRED_USE_A=(
	"${PYTHON_REQUIRED_USE}"

	"image? ( exif )"
	"video? ( exif )"
)
RESTRICT+=""

inherit arrays

python_prepare_all() {
	eapply_user

	xdg_src_prepare
	distutils-r1_python_prepare_all
}

python_install_all() {
	local -a DOCS=( README.md doc/*.md )
	distutils-r1_python_install_all

	doman "doc/${PN}.1"

	doicon -s 512      "data/${PN}.png"
	doicon -s scalable "data/${PN}.svg"

# 	if use nautilus
# 	then
# 		insinto /usr/share/nautilus-python/extensions/
# 		doins nautilus/mat2.py
# 	fi
}
