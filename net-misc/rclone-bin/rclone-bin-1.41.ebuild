# Copyright 2016-2018 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2

EAPI=6
inherit rindeal

## functions: systemd_douserunit
inherit systemd

DESCRIPTION="rsync for cloud storage"
HOMEPAGE="https://rclone.org/ https://github.com/ncw/rclone"
LICENSE="MIT"

PN_NB="${PN%-bin}"
SLOT="0"

SRC_URI=""
KEYWORDS="-*"
for _a in amd64 arm arm64 ; do
	SRC_URI+=" ${_a}? ( https://github.com/ncw/${PN_NB}/releases/download/v${PV}/${PN_NB}-v${PV}-linux-${_a}.zip )"
	KEYWORDS+=" ~${_a}"
done
unset _a

RDEPEND="!!${CATEGORY}/${PN_NB}"

RESTRICT+=" mirror"

src_unpack() {
	default

	cd "${WORKDIR}"/${PN_NB}-*/ || die
	S="${PWD}"
}

inst_d="/opt/${PN_NB}"

src_install() {
	into "${inst_d}"
	dobin "${PN_NB}"
	dosym "${inst_d}/bin/${PN_NB}" "/usr/bin/${PN_NB}"

	doman "${PN_NB}.1"
	dodoc README.*

	systemd_douserunit "${FILESDIR}/rclone-mount@.service"
}

QA_PRESTRIPPED="${inst_d#/}/bin/${PN_NB}"
