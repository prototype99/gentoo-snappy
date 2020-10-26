# Copyright 2017 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2

EAPI=6
inherit rindeal

# functions: udev_dorules, udev_reload
inherit udev

DESCRIPTION="Set of misc snippets enhancing the default system configuration"
HOMEPAGE="https://wiki.gentoo.org/wiki/No_homepage"
LICENSE="GPL-2"

SLOT="0"

KEYWORDS="~amd64 ~arm ~arm64"
IUSE_A=( udev )

CDEPEND_A=( )
DEPEND_A=( "${CDEPEND_A[@]}" )
RDEPEND_A=( "${CDEPEND_A[@]}"
	"udev? ( virtual/udev )"
)

REQUIRED_USE_A=(  )
RESTRICT+=""

inherit arrays

S="${WORKDIR}"

src_unpack() { : ; }
src_configure() { : ; }
src_compile() { : ; }

src_install() {
	if use udev ; then
		udev_dorules "${FILESDIR}"/udev/60-SSD-scheduler.rules
	fi

	insinto /lib/modprobe.d/
	doins "${FILESDIR}"/modprobe.d/50-snd_hda_intel.conf

	# `[QLibraryInfo::DataPath]/qtlogging.ini`
	# hardcoded in qt5-build.eclass
	QT5_DATADIR="${EPREFIX}/usr/share/qt5"

	## Silence debugging messages in KDE (and possible other Qt-based) apps.
	## User customizations can be made to `~/.config/QtProject/qtlogging.ini` file manually
	## or with the kdebugsettings GUI app.
	insinto "${QT5_DATADIR}"
	doins "${FILESDIR}"/qt5/qtlogging.ini
}

pkg_postinst() {
	udev_reload
}
