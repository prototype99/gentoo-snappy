# Copyright 2019 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2

EAPI=7
inherit rindeal

## github.eclass:
GITHUB_NS="google"

## python-r1.eclass:
PYTHON_COMPAT=( python2_7 python3_{5,6,7} )

## functions: github:src_unpack
## variables: GITHUB_HOMEPAGE, GITHUB_SRC_URI
inherit github

## EXPORT_FUNCTIONS: src_prepare src_configure src_compile src_test src_install
inherit distutils-r1

DESCRIPTION="Static type analyzer for Python code"
HOMEPAGE_A=(
	"${GITHUB_HOMEPAGE}"
)
LICENSE="Apache-2.0"

SLOT="0"
SRC_URI_A=(
	"${GITHUB_SRC_URI}"
)

KEYWORDS="~amd64 ~arm ~arm64"
IUSE_A=(
)

CDEPEND_A=(
	# uses 'console_scripts' so it has runtime dep as well
	"dev-python/setuptools[${PYTHON_USEDEP}]"
)
DEPEND_A=( "${CDEPEND_A[@]}"
	"sys-apps/gawk"  # for python_prepare_all patching
)
RDEPEND_A=( "${CDEPEND_A[@]}"
	"dev-python/attrs[${PYTHON_USEDEP}]"
	">=dev-python/importlab-0.5.1[${PYTHON_USEDEP}]"
	"dev-util/ninja"
	"dev-python/pyyaml[${PYTHON_USEDEP}]"
	"=dev-python/six-1*[${PYTHON_USEDEP}]"
	"$(python_gen_cond_dep \
		'dev-python/typed-ast[${PYTHON_USEDEP}]' \
			'python-3'
	)"
	"dev-python/typeshed:*"
)

inherit arrays

src_unpack() {
	github:src_unpack
}

python_prepare_all() {
	## prevent double build during install step
	rsed -r -e "s/(if *build_utils *):/\1 and sys.argv[1] == 'build':/"  -i -- setup.py
	rsed -e 's@build_utils.clean_generated_files()@pass@' -i -- setup.py

	## do not use internal typeshed
	rsed -r -e "/typeshed.*scan_package_data/,+1d" -i -- setup.py
	rsed -r -e '/return .*typeshed/ s@\+ *typeshed@@' -i -- setup.py

	## no tests
	einfo "Removing tests..."
	NO_V=1 rrm -r "${PN}"/tests
	find . -type f -\( -name "*test.py" -o -name "test*.py" -\) -print -delete || die
	rsed -e '/googletest/d' -i -- CMakeLists.txt
	rsed -r -e '/add_subdirectory.*( *tests *)/d' -i -- ${PN}/CMakeLists.txt || die
	# delete py_test macros
	local -- gawk_script='/^py_test/{in_py_test=1} !in_py_test{print} /)$/{in_py_test=0}'
	find . -type f -name 'CMakeLists.txt' -print0 | xargs -0 gawk -i inplace "${gawk_script}"
	assert

	## this is not a python dep, but runtime cmd dep, so do not specify it in setup.py
	rsed -e "/'ninja',/d" -i -- setup.py

	distutils-r1_python_prepare_all
}

python_install() {
	distutils-r1_python_install

	local -- sitedir
	sitedir="$(python_get_sitedir)"
	sitedir="${sitedir#${EPREFIX}}"
	rdosym --rel -- "/usr/share/typeshed" "${sitedir}/${PN}/typeshed"
}
