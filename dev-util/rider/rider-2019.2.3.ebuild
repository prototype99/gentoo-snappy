# Copyright 2018 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2

EAPI=7

JBIJ_PN_PRETTY="Rider"
JBIJ_URI="rider/JetBrains.Rider-${PV}"

inherit jetbrains-intellij

DESCRIPTION="Cross-platform .NET IDE based on the IntelliJ platform and ReSharper"

RDEPEND_A=(
	# TODO: unbundle mono
	# "dev-lang/mono"
)

inherit arrays

src_prepare() {
	JBIJ_ADDITIONAL_EXECUTABLES=(
		lib/ReSharperHost/runtime.sh
		lib/ReSharperHost/*/mono/bin/*
	)

	jetbrains-intellij_src_prepare
}

JBIJ_DESKTOP_EXTRAS=(
	# mimetypes taken from monodevelop.desktop file
	"MimeType=text/x-csharp;application/x-mds;application/x-mdp;application/x-cmbx;application/x-prjx;application/x-csproj;application/x-vbproj;application/x-sln;application/x-aspx;text/xml;application/xhtml+xml;text/html;text/plain;" # MUST end with semicolon
)
