# Copyright 1999-2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=6

DESCRIPTION="Provides /etc/mime.types file"
SLOT="0"
KEYWORDS="amd64"
IUSE="gentoo +mailcap"

REQUIRED_USE="^^ ( gentoo mailcap )"

RDEPEND="
	gentoo? ( app-misc/mime-types )
	mailcap? ( app-misc/mime-types-mailcap )
	"
