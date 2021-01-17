# Copyright 1999-2018 Gentoo Foundation
# Copyright 2018 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2

EAPI=6
inherit rindeal

## git-hosting.eclass:
GH_RN="github"

## python-*.eclass:
PYTHON_COMPAT=( python3_{5,6} )
PYTHON_REQ_USE='readline,sqlite,threads(+)'

## distutils-r1.eclass:
DISTUTILS_IN_SOURCE_BUILD=1

## EXPORT_FUNCTIONS: src_unpack
inherit git-hosting

## EXPORT_FUNCTIONS: src_prepare src_configure src_compile src_test src_install
inherit distutils-r1

## functions: optfeature()
inherit eutils

DESCRIPTION="Advanced interactive shell for Python"
HOMEPAGE="https://ipython.org/ ${GH_HOMEPAGE}"
LICENSE="BSD"

SLOT="0"

KEYWORDS="amd64 ~arm ~arm64"
IUSE_A=(  )

CDEPEND_A=( )
DEPEND_A=( "${CDEPEND_A[@]}"
	">=dev-python/setuptools-18.5[${PYTHON_USEDEP}]"
)
RDEPEND_A=( "${CDEPEND_A[@]}"
	"dev-python/decorator[${PYTHON_USEDEP}]"
	">=dev-python/jedi-0.10.0[${PYTHON_USEDEP}]"
	"dev-python/pexpect[${PYTHON_USEDEP}]"
	"dev-python/pickleshare[${PYTHON_USEDEP}]"
	">=dev-python/prompt_toolkit-1.0.4[${PYTHON_USEDEP}]" "<dev-python/prompt_toolkit-2[${PYTHON_USEDEP}]"
	"dev-python/pyparsing[${PYTHON_USEDEP}]"
	"dev-python/simplegeneric[${PYTHON_USEDEP}]"
	">=dev-python/traitlets-4.2.1[${PYTHON_USEDEP}]"
)

inherit arrays

python_prepare_all() {
	# Remove out of date insource files
	rrm IPython/extensions/cythonmagic.py
	rrm IPython/extensions/rmagic.py

	# Prevent un-needed download during build
	rsed -e "/^    'sphinx.ext.intersphinx',/d" -i -- docs/source/conf.py

	# prevent tests from being installed
	rsed -e "/if any(package.startswith('IPython.'+exc)/i \        if '.tests' in package:\n            continue" -i -- setupbase.py

	distutils-r1_python_prepare_all
}

python_install() {
	distutils-r1_python_install

	# Create ipythonX.Y symlinks.
	# TODO:
	# 1. do we want them for pypy? No.  pypy has no numpy
	# 2. handle it in the eclass instead (use _python_ln_rel).
	# With pypy not an option the dosym becomes unconditional
	dosym ../lib/python-exec/${EPYTHON}/ipython \
		/usr/bin/ipython${EPYTHON#python}
}

pkg_postinst() {
	optfeature "sympyprinting" dev-python/sympy
	optfeature "%lprun magic command" dev-python/line_profiler
	optfeature "%mprun magic command" dev-python/memory_profiler
}
