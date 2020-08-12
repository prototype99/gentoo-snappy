# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit git-r3

DESCRIPTION='Generally mirror libc but use direct syscalls'
HOMEPAGE='https://chromium.googlesource.com/linux-syscall-support'
SRC_URI=''
EGIT_COMMIT="be2d5a80"
EGIT_REPO_URI="https://chromium.googlesource.com/${PN}"

LICENSE='Google-TOS'
SLOT='0'
KEYWORDS='amd64'
IUSE=''

DEPEND=''
RDEPEND=''

DOCS=(
	'README.md'
)

src_install() {
	doheader *.h

	default
}
