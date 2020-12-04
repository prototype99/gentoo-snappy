# Copyright 1999-2020 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

DESCRIPTION="Advanced file manager for Linux written in Vala. Supports multiple panes (single, dual, quad) with multiple tabs in each pane. Supports archive creation, extraction and browsing. Support for cloud storage; running and managing KVM images, modifying PDF documents and image files, booting ISO files in KVM, and writing ISO files to USB drives."
HOMEPAGE="https://github.com/RogueScholar/polo/"
NUM="1f42c5f6b5452bc77a530f094d2174dd7847d39f"
SRC_URI="${HOMEPAGE}archive/${NUM}.zip -> ${P}.zip"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="amd64 ~x86"
IUSE="cloud +fm-comp-prog prop-exif prop-media +thumb-vid"

DEPEND="x11-libs/gtk+
	gnome-base/gvfs
	dev-libs/libgee
	net-libs/libsoup
	app-arch/p7zip
	net-misc/rsync
	x11-libs/vte
	dev-lang/vala"
RDEPEND="${DEPEND}
	cloud? ( net-misc/rclone )
	fm-comp-prog? ( sys-apps/pv )
	prop-exif? ( media-libs/exiftool )
	prop-media? ( media-video/mediainfo )
	thumb-vid? ( media-video/ffmpeg )"

S="${WORKDIR}/${PN}-${NUM}"