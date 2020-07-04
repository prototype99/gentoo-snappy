# Copyright 2017,2019 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2

# @ECLASS: rindeal-python-utils.eclass

if ! (( _RINDEAL_PYTHON_UTILS_ECLASS ))
then

case "${EAPI:-0}" in
6 | 7 ) ;;
* ) die "Unsupported EAPI='${EAPI}' for '${ECLASS}'" ;;
esac


# functions: makeopts_jobs()
inherit multiprocessing


## compile python bindings in parallel
## https://stackoverflow.com/a/13176803/2566213
make_setup.py_extension_compilation_parallel() {
	local file="${1}"

	local build_py_monkey_patch
	read -r -d '' build_py_monkey_patch <<_EOF_
# BEGIN: monkey parallel patch
def parallelCCompile(self, sources, output_dir=None, macros=None, include_dirs=None, debug=0, extra_preargs=None, extra_postargs=None, depends=None):
	# those lines are copied from distutils.ccompiler.CCompiler directly
	macros, objects, extra_postargs, pp_opts, build = self._setup_compile(output_dir, macros, include_dirs, sources, depends, extra_postargs)
	cc_args = self._get_cc_args(pp_opts, debug, extra_preargs)
	# parallel code
	N=$(makeopts_jobs) # number of parallel compilations
	import multiprocessing.pool
	def _single_compile(obj):
		try: src, ext = build[obj]
		except KeyError: return
		self._compile(obj, src, ext, cc_args, extra_postargs, pp_opts)
	# convert to list, imap is evaluated on-demand
	list(multiprocessing.pool.ThreadPool(N).imap(_single_compile, objects))
	return objects
import distutils.ccompiler
distutils.ccompiler.CCompiler.compile=parallelCCompile
# END: monkey parallel patch
_EOF_
	gawk -i inplace -vmonkey_patch="${build_py_monkey_patch}" \
		'/^(setuptools.)?setup *\(/ { print monkey_patch ; print ; next }1' \
		"${file}" || die
}


_RINDEAL_PYTHON_UTILS_ECLASS=1
fi
