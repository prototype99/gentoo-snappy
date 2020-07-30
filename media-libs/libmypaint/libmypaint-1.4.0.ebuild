# Copyright 2019 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2

EAPI=7
inherit rindeal

## github.eclass:
GITHUB_NS="mypaint"
GITHUB_REF="v${PV}"

## python-*.eclass:
PYTHON_COMPAT=( python2_7 )

##
inherit github

## python2 is used in autogen.sh
## variables: PYTHON_DEPS
inherit python-any-r1

## functions: prune_libtool_files
inherit ltprune

DESCRIPTION="Library for making brushstrokes"
HOMEPAGE_A=(
	"${GITHUB_HOMEPAGE}"
	"http://mypaint.org/"
)
LICENSE_A=(
	"ISC"
)

# NOTE: upstream uses a weird SONAME versioning, so it's unlikely subslot will be bumped
SLOT="0/0"
SRC_URI_A=(
	"${GITHUB_SRC_URI}"
)

## TODO: make it unstable in v1.5.x
KEYWORDS="amd64 arm arm64"
IUSE_A=(
	threads
	nls
	introspection
	gegl
)

CDEPEND_A=(
	"introspection? ( dev-libs/glib:2= )"
	"dev-libs/json-c:="
	"gegl? ("
		"media-libs/babl:0="
		">=media-libs/gegl-0.4.14:0.4=[introspection?]"
	")"
	"introspection? ( >=dev-libs/gobject-introspection-1.32 )"
	"threads? ( virtual/openmp:0 )"
	"nls? ( sys-devel/gettext )"
)
DEPEND_A=( "${CDEPEND_A[@]}"
	"${PYTHON_DEPS}"
	"nls? ( dev-util/intltool )"
)
RDEPEND_A=( "${CDEPEND_A[@]}" )

REQUIRED_USE_A=(
)
RESTRICT+=""

inherit arrays

pkg_setup()
{
	python-any-r1_pkg_setup
}

src_unpack()
{
	github:src_unpack
}

src_prepare()
{
	# https://github.com/mypaint/libmypaint/issues/144
	eapply -R "${FILESDIR}/5e0290c5fb8a175a9f0dd4c6897ff234361c321f.patch"

	eapply "${FILESDIR}/libmypaint-1.3.0-gegl-0.4.14.patch"

	eapply_user

	rsed -e "/FLAGS *=/ s/-O[0-9]//" -i -- configure.ac

	## eautoreconf fails, because it tries to execute gettext macros even if gettext is not requested
	./autogen.sh || die
}

src_configure()
{
	local -a my_econf_args=(
		### Optional Features:
		--disable-debug
		--disable-profiling
		$(use_enable threads openmp)
		--disable-gperftools
		--disable-docs
		$(use_enable nls i18n)
		$(use_enable nls)
		$(use_enable introspection)
		$(use_enable gegl)
		--disable-gegl
		--disable-introspection

		### Optional Packages:
		$(use_with introspection glib)
	)
	econf "${my_econf_args[@]}"
}

src_install()
{
	default

	prune_libtool_files
}
