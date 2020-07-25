# Copyright 2016-2019 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2

EAPI="7"
inherit rindeal

## functions: append-cppflags, append-cflags, append-ldflags
inherit flag-o-matic

## functions: tc-getPKG_CONFIG
inherit toolchain-funcs

## functions: dohelp2man
inherit help2man

DESCRIPTION="Nigel's performance MONitor for CPU, memory, network, disks, etc..."
HOMEPAGE_A=(
	"https://nmon.sourceforge.net/"
)
LICENSE_A=(
	"GPL-3.0-or-later"
)

SLOT="0"

SRC_URI_A=(
	"mirror://sourceforge/${PN}/lmon${PV}.c"
)

KEYWORDS="amd64 arm arm64"

CDEPEND_A=(
	"sys-libs/ncurses:0="
)
DEPEND_A=( "${CDEPEND_A[@]}"
	"virtual/pkgconfig"
)
RDEPEND_A=( "${CDEPEND_A[@]}"
)

inherit arrays

S="${WORKDIR}"

src_unpack()
{
	rcp --preserve=timestamps "${DISTDIR}/"*.c "${S}/${PN}.c"
}

src_configure()
{
	local -a cppflags=(
		## archs
		$(usex amd64 "-DX86=1" "")
		$(usex arm   "-DARM=1" "")
	)
	append-cppflags "${cppflags[@]}"
	append-cflags  "$( $(tc-getPKG_CONFIG) --cflags                    ncurses )"
	append-ldflags "$( $(tc-getPKG_CONFIG) --libs-only-other           ncurses )"
	export LDLIBS=" $( $(tc-getPKG_CONFIG) --libs-only-L --libs-only-l ncurses ) -lm"
}

src_compile()
{
	emake "${PN}"
}

src_install()
{
	dobin "${PN}"

	HELP2MAN_OPTS=(
		--name="Performance Monitor"
	)
	dohelp2man "${PN}"

	newenvd "${FILESDIR}/${PN}.envd" "70${PN}"
}
