# Copyright 2016-2017 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2

EAPI=6
inherit rindeal

GH_RN="github:dsoprea"

PYTHON_COMPAT=( python2_7 )

inherit git-hosting
inherit distutils-r1

DESCRIPTION="Innovative FUSE wrapper for Google Drive"
LICENSE="GPL-2"

SLOT="0"

KEYWORDS="~amd64 ~arm ~arm64"

# requirements are in `gdrivefs/resources/requirements.txt`
CDEPEND_A=(
	"=dev-python/fusepy-2.0*[${PYTHON_USEDEP}]"
	"=dev-python/gevent-1*[${PYTHON_USEDEP}]"
	"=dev-python/google-api-python-client-1*[${PYTHON_USEDEP}]"
	"=dev-python/greenlet-0.4*[${PYTHON_USEDEP}]"
	"=dev-python/httplib2-0*[${PYTHON_USEDEP}]"
	"=dev-python/python-dateutil-2*[${PYTHON_USEDEP}]"
	"=dev-python/six-1*[${PYTHON_USEDEP}]"
)
DEPEND_A=( "${CDEPEND_A[@]}" )
RDEPEND_A=( "${CDEPEND_A[@]}" )

inherit arrays

src_prepare() {
	# https://github.com/dsoprea/GDriveFS/pull/168
	sed -r -e '/packages=/ s|(exclude=\[)|\1"tests.*", |' -i -- setup.py || die

	distutils-r1_src_prepare
}
