# Copyright 1999-2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI="7"

inherit multilib-build

DESCRIPTION="Virtual for BLAS C implementation"
SLOT="0"
KEYWORDS="~alpha amd64 arm arm64 hppa ~ia64 ppc ppc64 ~s390 sparc x86 ~amd64-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos"
IUSE="eselect-ldso int64"

RDEPEND="
	|| (
		>=sci-libs/cblas-reference-20110218-r1[int64?,${MULTILIB_USEDEP}]
		sci-libs/openblas[eselect-ldso?,int64?,${MULTILIB_USEDEP}]
		abi_x86_64? (
			!abi_x86_32? (
				|| (
					>=sci-libs/gotoblas2-1.13[int64?,${MULTILIB_USEDEP}]
					>=sci-libs/mkl-10.3[int64?,${MULTILIB_USEDEP}]
					sci-libs/libsci
				)
			)
	)
		!int64? (
			|| (
				sci-libs/blis[eselect-ldso?]
				>=sci-libs/atlas-3.9.34
				>=sci-libs/gsl-1.16-r2[-cblas-external,${MULTILIB_USEDEP}]
				>=sci-libs/lapack-3.8.0[eselect-ldso?]
			)
			arm? (
				 >=sci-libs/atlas-3.9.34
			)
		)
	)"
DEPEND="${RDEPEND}"
