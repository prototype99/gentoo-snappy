# Copyright 2017-2019 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2

EAPI=7
inherit rindeal

## github.eclass:
GITHUB_NS="python"
GITHUB_REF="v${PV}"

## python-*.eclass:
PYTHON_COMPAT=( python3_{5,6,7} )

inherit github

## EXPORT_FUNCTIONS: src_prepare src_configure src_compile src_test src_install
inherit distutils-r1

DESCRIPTION="Optional static typing for Python"
HOMEPAGE_A=(
	"http://www.mypy-lang.org/"
	"${GITHUB_HOMEPAGE}"
)
LICENSE="MIT"

SLOT="0"
SRC_URI_A=(
	"${GITHUB_SRC_URI}"
)

KEYWORDS="~amd64 ~arm ~arm64"

CDEPEND_A=( )
DEPEND_A=( "${CDEPEND_A[@]}"
	"dev-python/setuptools[${PYTHON_USEDEP}]"
)
RDEPEND_A=( "${CDEPEND_A[@]}"
	# NOTE > remember to bump < NOTE
	"~dev-python/typeshed-0.0.0.0_p20190904"
	# NOTE ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ NOTE
	">=dev-python/typed-ast-1.4.0[${PYTHON_USEDEP}]"
	"<dev-python/typed-ast-1.5.0[${PYTHON_USEDEP}]"
	"$(python_gen_cond_dep \
		'>=dev-python/typing-extensions-3.7.4[${PYTHON_USEDEP}]' \
			'python3_'{5,6}
	)"
	">=dev-python/mypy_extensions-0.4.0[${PYTHON_USEDEP}]"
	"<dev-python/mypy_extensions-0.5.0[${PYTHON_USEDEP}]"
)

inherit arrays

src_unpack()
{
	github:src_unpack
}

python_prepare_all()
{
	# no tests
	rsed -e "s/'mypy.test',//" -e "s/'mypyc.test',//" -i -- setup.py

	distutils-r1_python_prepare_all
}

python_install()
{
	distutils-r1_python_install

	## link to system typeshed installation
	python_export PYTHON_SITEDIR
	rdosym --rel -- /usr/share/typeshed "${PYTHON_SITEDIR}/${PN}/typeshed"
}
