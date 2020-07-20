# Copyright 2017,2019 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2

EAPI=7
inherit rindeal

GITHUB_NS="python"
GITHUB_PROJ="${PN//-/_}"

PYTHON_COMPAT=( python3_{5,6,7} )

inherit github
inherit distutils-r1

DESCRIPTION="Modified fork of CPython's ast module that parses \`# type:\` comments"
HOMEPAGE="${GITHUB_HOMEPAGE}"
LICENSE_A=(
	"Apache-2.0"
	"PSF-2"
)

SLOT="0"
SRC_URI_A=(
	"${GITHUB_SRC_URI}"
)

KEYWORDS="~amd64 ~arm ~arm64"
IUSE=""

inherit arrays

src_unpack()
{
	github:src_unpack
}

python_prepare_all()
{
	eapply_user

	rsed -e "\|package_dir={ 'typed_ast.tests': 'ast3/tests' },|d" -e "s/'typed_ast.tests'//" -i -- setup.py

	distutils-r1_python_prepare_all
}
