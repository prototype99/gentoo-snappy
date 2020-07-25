# Copyright 2016 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2

EAPI=7

JBIJ_PN_PRETTY='WebStorm'
JBIJ_URI="webstorm/WebStorm-${PV}"

inherit jetbrains-intellij

DESCRIPTION="WebStorm is an IDE for complex client-/server-side JavaScript development"

JBIJ_DESKTOP_CATEGORIES=( 'WebDevelopment' )
JBIJ_DESKTOP_EXTRAS=(
	"MimeType=text/x-php;text/html;" # MUST end with semicolon
)
