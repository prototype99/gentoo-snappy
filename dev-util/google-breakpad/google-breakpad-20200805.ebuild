# Copyright 1999-2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit git-r3 flag-o-matic

DESCRIPTION="An open-source multi-platform crash reporting system'"
HOMEPAGE="https://chromium.googlesource.com/breakpad/breakpad"
SRC_URI=""
EGIT_COMMIT="3d8daa2c"
EGIT_REPO_URI="https://chromium.googlesource.com/breakpad/breakpad"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

DEPEND="
	dev-cpp/gtest
	dev-libs/protobuf
	dev-util/gyp
	sys-libs/linux-syscall-support:=
"
RDEPEND=""

# TODO remove bundled src/third_party

src_unpack() {

	git-r3_src_unpack

	mkdir "${S}/src/third_party/lss" || die "unable to create ${S}"
	ln "${ROOT}/usr/include/linux_syscall_support.h" "${S}/src/third_party/lss" ||
		die 'unable to copy linux_syscall_support.h'

	default
}
