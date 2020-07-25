# Copyright 1999-2016 Gentoo Foundation
# Copyright 2016-2018 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2

EAPI=6
inherit rindeal

## git-hosting.eclass:
GH_RN="github:hishamhm"

## functions: eautoreconf
inherit autotools
## EXPORT_FUNCTIONS: pkg_setup
inherit linux-info
## EXPORT_FUNCTIONS: src_unpack
inherit git-hosting
## EXPORT_FUNCTIONS: src_prepare, pkg_preinst, pkg_postinst, pkg_postrm
inherit xdg
inherit desktop

DESCRIPTION="Interactive text-mode process viewer for Unix systems aiming to be a better top"
HOMEPAGE="https://hisham.hm/htop/ ${GH_HOMEPAGE}"
LICENSE="GPL-2"

SLOT="0"

KEYWORDS="amd64 arm ~arm64"
IUSE_A=( +cgroup hwloc +linux-affinity delayacct openvz unicode taskstats vserver )

CDEPEND_A=(
	"hwloc? ( sys-apps/hwloc )"
	"sys-libs/ncurses:0=[unicode?]"
	"delayacct? ( dev-libs/libnl:3 )"
)
DEPEND_A=( "${CDEPEND_A[@]}"
	"virtual/pkgconfig"
)
RDEPEND_A=( "${CDEPEND_A[@]}" )

REQUIRED_USE_A=(
	"?? ( hwloc linux-affinity )"
)

inherit arrays

pkg_setup() {
	if ! has_version sys-process/lsof ; then
		einfo "To use lsof features in htop (what processes are accessing"
		einfo "what files), you must have sys-process/lsof installed."
	fi
	if ! has_version dev-util/strace ; then
		einfo "To use strace features in htop (what processes are calling"
		einfo "what syscalls), you must have dev-util/strace installed."
	fi

	CONFIG_CHECK="
		$(usex taskstats '~TASKSTATS' '')"
	linux-info_pkg_setup
}

src_prepare() {
	eapply "${FILESDIR}"/2.0.2-bb8dec15829bb90ef2e637312e45e90b8ab4c64b.patch  # [PATCH] Cap battery at 100%.
	eapply "${FILESDIR}"/2.0.2-parseBatInfo-check-for-null-string.patch  # https://github.com/hishamhm/htop/pull/620
	eapply "${FILESDIR}"/2.0.2-Highlight_zombies.patch  # https://github.com/hishamhm/htop/pull/621
	eapply "${FILESDIR}"/2.2.0-Improve_htop_desktop_file.patch  # https://github.com/hishamhm/htop/pull/609
	eapply_user

	xdg_src_prepare

	eautoreconf
}

src_configure() {
	local my_econf_args=(
		--enable-proc  # use Linux-compatible proc filesystem, disable only for non-Linux

		$(use_enable hwloc)           # enable hwloc support for CPU affinity
		$(use_enable linux-affinity)  # enable Linux sched_setaffinity and sched_getaffinity for affinity support, disables hwloc
		$(use_enable delayacct)  # enable linux delay accounting

		$(use_enable cgroup)
		$(use_enable openvz)
		$(use_enable taskstats)  # enable per-task IO Stats (taskstats kernel support required)
		$(use_enable unicode)
		$(use_enable vserver)
	)
	econf "${my_econf_args[@]}"
}

src_install() {
	default

	doicon -s 128 ${PN}.png

	insinto /etc
	newins "${FILESDIR}"/2.0.2-htoprc htoprc
}
