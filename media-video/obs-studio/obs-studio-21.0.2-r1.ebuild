# Copyright 1999-2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=6

CMAKE_MIN_VERSION=3.9.6

inherit cmake-utils gnome2-utils

SRC_URI="https://github.com/obsproject/${PN}/archive/${PV}.tar.gz -> ${P}.tar.gz"
KEYWORDS="~amd64 ~x86"

DESCRIPTION="Software for Recording and Streaming Live Video Content"
HOMEPAGE="https://obsproject.com"

LICENSE="GPL-2"
SLOT="0"
IUSE="+alsa fdk imagemagick jack nvenc pulseaudio truetype v4l"

COMMON_DEPEND="
	>=dev-libs/jansson-2.5
	dev-lang/python:3.5
	dev-qt/qtcore:5
	dev-qt/qtdeclarative:5
	dev-qt/qtgui:5
	dev-qt/qtmultimedia:5
	dev-qt/qtnetwork:5
	dev-qt/qtquickcontrols:5
	dev-qt/qtsql:5
	dev-qt/qttest:5
	dev-qt/qtwidgets:5
	dev-qt/qtx11extras:5
	media-video/ffmpeg:=[x264]
	nvenc? ( media-video/ffmpeg:=[nvenc] )
	net-misc/curl
	x11-libs/libXcomposite
	x11-libs/libXinerama
	x11-libs/libXrandr
	alsa? ( media-libs/alsa-lib )
	fdk? ( media-libs/fdk-aac:= )
	imagemagick? ( media-gfx/imagemagick:= )
	jack? ( virtual/jack )
	pulseaudio? ( media-sound/pulseaudio )
	truetype? (
		media-libs/fontconfig
		media-libs/freetype
	)
	v4l? ( media-libs/libv4l )
"
DEPEND="${COMMON_DEPEND}"
RDEPEND="${COMMON_DEPEND}"

PATCHES="${FILESDIR}/${PN}-21.0.2-qt-5.11.0.patch"

CMAKE_REMOVE_MODULES_LIST=( FindFreetype )

src_configure() {
	local libdir=$(get_libdir)
	local mycmakeargs=(
		-DDISABLE_ALSA=$(usex !alsa)
		-DDISABLE_FREETYPE=$(usex !truetype)
		-DDISABLE_JACK=$(usex !jack)
		-DDISABLE_LIBFDK=$(usex !fdk)
		-DDISABLE_PULSEAUDIO=$(usex !pulseaudio)
		-DDISABLE_V4L2=$(usex !v4l)
		-DLIBOBS_PREFER_IMAGEMAGICK=$(usex imagemagick)
		-DOBS_MULTIARCH_SUFFIX=${libdir#lib}
		-DOBS_VERSION_OVERRIDE=${PV}
		-DUNIX_STRUCTURE=1
	)
	cmake-utils_src_configure
}

pkg_postinst() {
	gnome2_icon_cache_update

	if ! use alsa && ! use pulseaudio; then
		elog
		elog "For the audio capture features to be available,"
		elog "either the 'alsa' or the 'pulseaudio' USE-flag needs to"
		elog "be enabled."
		elog
	fi

	if ! has_version "sys-apps/dbus"; then
		elog
		elog "The 'sys-apps/dbus' package is not installed, but"
		elog "could be used for disabling hibernating, screensaving,"
		elog "and sleeping.  Where it is not installed,"
		elog "'xdg-screensaver reset' is used instead"
		elog "(if 'x11-misc/xdg-utils' is installed)."
		elog
	fi

	if ! has_version "media-libs/speexdsp"; then
		elog
		elog "For the speexdsp-based noise suppression filter"
		elog "to be available, the 'media-libs/speexdsp' package needs"
		elog "to be installed."
		elog
	fi
}

pkg_postrm() {
	gnome2_icon_cache_update
}
