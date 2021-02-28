# Copyright 1999-2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=6

DESCRIPTION="Provides libunwind"
SLOT="0"
KEYWORDS="amd64"
IUSE="+llvm nongnu"

REQUIRED_USE="^^ ( llvm nongnu )"

RDEPEND="
	llvm? ( >=sys-libs/llvm-libunwind-11.0.0_rc3 )
	nongnu? ( >=sys-libs/libunwind-1.2_rc1 )
	"
