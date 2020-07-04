# Copyright 1999-2016 Gentoo Foundation
# Copyright 2016-2019 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2

if ! (( _LIBTORRENT_RASTERBAR_ECLASS ))
then

case "${EAPI:-0}" in
7 ) ;;
* ) die "Unsupported EAPI='${EAPI}' for '${ECLASS}'" ;;
esac

inherit rindeal


## python-*.eclass:
[[ -z "${PYTHON_COMPAT}" ]] && \
	PYTHON_COMPAT=( python2_7 python3_{5,6,7} )
[[ -z "${PYTHON_REQ_USE}" ]] && \
	PYTHON_REQ_USE="threads(+)"

## distutils-r1.eclass:
[[ -z "${DISTUTILS_OPTIONAL}" ]] && \
	DISTUTILS_OPTIONAL=true
[[ -z "${DISTUTILS_IN_SOURCE_BUILD}" ]] && \
	DISTUTILS_IN_SOURCE_BUILD=true

## git-hosting.eclass:
GH_RN='github:arvidn:libtorrent'
GH_FETCH_TYPE='manual'


## EXPORT_FUNCTIONS: src_unpack
inherit git-hosting

## (optional) EXPORT_FUNCTIONS: src_prepare src_configure src_compile src_install
inherit distutils-r1

## functions: make_setup.py_extension_compilation_parallel
inherit rindeal-python-utils

## functions: eautoreconf
inherit autotools

## functions: append-cxxflags
inherit flag-o-matic

## functions: prune_libtool_files
inherit ltprune

if ver_test "${PV}" -ge "1.2.0"
then
	## EXPORT_FUNCTIONS: src_prepare src_configure src_compile src_test src_install
	inherit cmake-utils
fi

DESCRIPTION='C++ BitTorrent implementation focusing on efficiency and scalability'
HOMEPAGE="https://libtorrent.org/ ${GH_HOMEPAGE}"
LICENSE='BSD'


[[ -z "${LT_SONAME}" ]] && die "LT_SONAME not defined or empty"
SLOT="0/${LT_SONAME}"
# upstream devs randomly change back and forth between using score and undescore to delimit name and version
git-hosting_gen_snapshot_url "${GH_RN}" "libtorrent-${PV//./_}" _my_snapshot_url_v1 _LTR_DISTFILE_v1
git-hosting_gen_snapshot_url "${GH_RN}" "libtorrent_${PV//./_}" _my_snapshot_url_v2 _my_snapshot_distfile_v2
SRC_URI_A=(
	"${_my_snapshot_url_v1} -> ${_LTR_DISTFILE_v1}"
	"${_my_snapshot_url_v2} -> ${_LTR_DISTFILE_v1}"
)
unset _my_snapshot_url_v1 _my_snapshot_url_v2 _my_snapshot_distfile_v2


IUSE_A=( +crypt debug +dht doc examples python static-libs )


CDEPEND_A=(
	"!!net-libs/rb_libtorrent"
	"dev-libs/boost:=[threads]"
	"virtual/libiconv"

	"crypt? ( dev-libs/openssl:0= )"
	"examples? ( !net-p2p/mldonkey )"
	"python? ( ${PYTHON_DEPS}"
		"dev-libs/boost:=[python,${PYTHON_USEDEP}]"
	")"
)
DEPEND_A=( "${CDEPEND_A[@]}"
	"sys-devel/libtool"
)

REQUIRED_USE_A=( "python? ( ${PYTHON_REQUIRED_USE} )" )
RESTRICT+=" test"

inherit arrays


EXPORT_FUNCTIONS src_unpack src_prepare src_configure src_compile src_install


libtorrent-rasterbar_src_unpack() {
	git-hosting_unpack "${DISTDIR}/${_LTR_DISTFILE_v1}" "${WORKDIR}/${P}"
}

libtorrent-rasterbar_src_prepare() {
	default

	# https://github.com/rindeal/gentoo-overlay/issues/28
	# make sure lib search dir points to the main `S` dir and not to python copies
	rsed -e "s|-L[^ ]*/src/\.libs|-L${S}/src/.libs|" \
		-i -- bindings/python/link_flags.in

	# respect optimization flags
	rsed -e '/DEBUGFLAGS *=/ s|-O[a-z0-9]||' \
		-i -- configure.ac

	make_setup.py_extension_compilation_parallel bindings/python/setup.py

	# automake fails miserably if this file doesn't exist
	rmkdir build-aux
	touch build-aux/config.rpath || die

	eautoreconf

	if use python
	then
		# this will copy current source directory into a separate directory for each python version
		distutils-r1_src_prepare
	fi
}

libtorrent-rasterbar_src_configure() {
	if ver_test "${PV}" -lt '1.2.0'
	then
		append-cxxflags -std=c++11 # Gentoo-Bug: 634506
	fi
	if ver_test "${PV}" -lt '1.1.0'
	then
		# v1.0.x is old and uses code which is deprecated in C++11
		append-cxxflags -Wno-deprecated-declarations
	fi

	local my_econf_args=(
		--disable-silent-rules # Gentoo-Bug: 441842
		# hardcode boost system to skip "lookup heuristic"
		--with-boost-system='mt'
		--with-libiconv

		$(use_enable crypt encryption)
		$(use_enable debug)
		$(use_enable debug disk-stats)
		$(use_enable debug logging verbose)
		$(use_enable dht dht $(usex debug logging yes))
		$(use_enable examples)
		$(use_enable static-libs static)
	)

	if ver_test "${PV}" -lt '1.1.0'
	then
		my_econf_args+=( $(use_enable debug statistics) )
	fi

	econf "${my_econf_args[@]}"

	if use python
	then
		python_configure() {
			local my_econf_args=( "${my_econf_args[@]}"
				--enable-python-binding
				--with-boost-python
			)
			econf "${my_econf_args[@]}"
		}
		distutils-r1_src_configure
	fi
}

libtorrent-rasterbar_src_compile() {
	default

	if use python
	then
		python_compile() {
			cd "${BUILD_DIR}"/../bindings/python || die
			distutils-r1_python_compile
		}
		distutils-r1_src_compile
	fi
}

libtorrent-rasterbar_src_install() {
	use doc && local HTML_DOCS+=( ./docs )

	default

	if use python
	then
		python_install() {
			cd "${BUILD_DIR}"/../bindings/python || die
			distutils-r1_python_install
		}
		distutils-r1_src_install
	fi

	prune_libtool_files
}


_LIBTORRENT_RASTERBAR_ECLASS=1
fi
