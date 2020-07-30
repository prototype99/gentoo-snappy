# Copyright 2018 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2

EAPI=6
inherit rindeal

## git-hosting.eclass:
GH_RN="github:intel"
GH_REF="release_${PV}"

## EXPORT_FUNCTIONS: src_unpack
inherit git-hosting
## functions: eautoreconf
inherit autotools
## functions: prune_libtool_files
inherit ltprune

DESCRIPTION="Project for extended camera features (image quality improvement, video analysis)"
LICENSE="Apache-2.0"

SLOT="0"

KEYWORDS="~amd64"
IUSE_A=(
	+shared-libs static-libs debug profiling
	drm
# 	aiq
	gst
	libcl
	opencv
	capi
# 	3alib
	smartlib
	doc
	gnu-ld
)

CDEPEND_A=(
	"drm? ( x11-libs/libdrm )"
	"libcl? ( virtual/opencl )"
	"libcl? ( drm? ( dev-libs/beignet ) )"
	">=media-libs/opencv-3"
	"gst? ("
		"media-libs/gstreamer:1.0"
		"media-libs/gst-plugins-base:1.0"  # GST_ALLOCATOR, GST_VIDEO
	")"
)
DEPEND_A=( "${CDEPEND_A[@]}"
	"doc? ( app-doc/doxygen )"
)
RDEPEND_A=( "${CDEPEND_A[@]}" )

REQUIRED_USE_A=(  )
RESTRICT+=""

inherit arrays

pkg_setup() {
	if use libcl && use drm && [[ "$(eselect opencl show)" != "beignet" ]] ; then
		die "USE='libc drm' requires 'beignet' opencl provider, issue: 'eselect opencl set beignet' to set it"
	fi
}

src_prepare() {
	eapply_user

	rsed -e "s| -fstack-protector||" -i -- configure.ac

	eautoreconf
}

src_configure() {
	local my_econf_args=(
		### Optional Features:
		$(use_enable shared-libs shared)
		$(use_enable static-libs static)
		$(use_enable debug)
		$(use_enable profiling)
		$(use_enable drm)
# 		$(use_enable aiq)  # Android
		--disable-aiq
		$(use_enable gst)
		$(use_enable libcl)
		$(use_enable opencv)
		$(use_enable capi)
		$(use_enable doc docs)
# 		$(use_enable 3alib)  # Android
		--disable-3alib
		$(use_enable smartlib)

		### Optional Packages:
		$(use_with gnu-ld)
	)
	econf "${my_econf_args[@]}"
}

src_install() {
	default

	exeinto "/usr/libexec/${PN}"
	doexe tests/.libs/*

	prune_libtool_files
}
