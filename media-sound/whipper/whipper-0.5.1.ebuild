# Copyright 2017 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2

EAPI=6
inherit rindeal

GH_RN="github:JoeLametta"
GH_REF="v${PV}"

PYTHON_COMPAT=( python2_7 )

# EXPORT_FUNCTIONS: src_unpack
inherit git-hosting
inherit distutils-r1
inherit toolchain-funcs

DESCRIPTION="Python CD-DA ripper preferring accuracy over speed (FORKED from morituri)"
LICENSE="GPL-3"

SLOT="0"

# arm has missing deps
KEYWORDS="~amd64"
IUSE_A=( )

CDEPEND_A=()
DEPEND_A=( "${CDEPEND_A[@]}" )
RDEPEND_A=( "${CDEPEND_A[@]}"
	"media-sound/cdparanoia" # for the actual ripping
	"app-cdr/cdrdao" #  for session, TOC, pre-gap, and ISRC extraction
	"dev-python/pygobject:2[${PYTHON_USEDEP}]" # required by task.py
	"dev-python/python-musicbrainz-ngs[${PYTHON_USEDEP}]" # for metadata lookup
	"media-libs/mutagen[${PYTHON_USEDEP}]" # for tagging support
	"dev-python/setuptools[${PYTHON_USEDEP}]" #  for installation, plugins support
	"media-libs/libcddb" #  for showing but not using metadata if disc not available in the MusicBrainz DB
	"dev-python/pycdio[${PYTHON_USEDEP}]" # for drive identification
	"media-libs/libsndfile" # for reading wav files
	"media-libs/flac" # for reading flac files
	"media-sound/sox" #  for track peak detection
)

inherit arrays

my_make() {
	make CC="$(tc-getCC)"
}

python_prepare_all() {
	sed -r -e '/^(C|LD)FLAGS *= */ s| = | \+= |' -i -- src/config.mk || die

	distutils-r1_python_prepare_all
}

python_compile_all() {
	rpushd "src"
	my_make
	rpopd

	distutils-r1_python_compile_all
}

python_install_all() {
	rpushd "src"
	dobin "accuraterip-checksum"
	rpopd

	distutils-r1_python_install_all
}
