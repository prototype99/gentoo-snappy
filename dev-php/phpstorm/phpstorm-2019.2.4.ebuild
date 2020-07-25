# Copyright 2016 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2

EAPI=7

JBIJ_PN_PRETTY='PhpStorm'
JBIJ_URI="webide/PhpStorm-${PV}"

inherit jetbrains-intellij

DESCRIPTION="PhpStorm is a commercial, cross-platform IDE for PHP"

JBIJ_DESKTOP_CATEGORIES=( 'WebDevelopment' )
JBIJ_DESKTOP_EXTRAS=(
	"MimeType=text/x-php;text/html;" # MUST end with semicolon
)
