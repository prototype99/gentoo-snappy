# SPDX-FileCopyrightText: 2019  Jan Chren (rindeal)  <dev.rindeal@gmail.com>
#
# SPDX-License-Identifier: GPL-2.0-only

##!
# @ECLASS: cgit.eclass
# @BLURB: eclass for packages with source code hosted on public cgit instances
# @EXAMPLE:
#
# @CODE
#
# CGIT_SVR="https://git.zx2c4.com"
# CGIT_DOT_GIT="yes"
# CGIT_NS="cgit"
# CGIT_PROJ="cgit"
# CGIT_REF="v${PV}"
# CGIT_SNAP_EXT=".tar.xz"
#
# ## functions cgit:src_unpack
# ## variables: CGIT_HOMEPAGE, CGIT_SRC_URI
# inherit cgit
#
# DESCRIPTION=""
# HOMEPAGE_A=(
# 	"${CGIT_HOMEPAGE}"
# )
# LICENSE_A=()
#
# SLOT="0"
#
# cgit:snap:gen_src_uri CGIT_NS="foo" CGIT_PROJ="bar" CGIT_REF="version-${PV}" \
# 	--url-var another_url --distfile-var another_distfile
# SRC_URI_A=(
# 	"${CGIT_SRC_URI}"
# 	"${another_url} -> ${another_distfile}"
# )
#
# IUSE_A=()
#
# CDEPEND_A=(
# )
# DEPEND_A=( "${CDEPEND_A[@]}"
# )
# RDEPEND_A=( "${CDEPEND_A[@]}"
# )
#
# REQUIRED_USE_A=(
# )
# RESTRICT+=""
#
# inherit arrays
#
# src_unpack() {
# 	cgit:src_unpack
# 	cgit:snap:unpack "${another_distfile}" "${WORKDIR}/another-proj"
# }
#
# @CODE
##!

if ! (( _CGIT_ECLASS ))
then

case "${EAPI:-"0"}" in
"7" ) ;;
* ) die "EAPI='${EAPI}' is not supported by ECLASS='${ECLASS}'" ;;
esac

inherit rindeal


### BEGIN: Inherits

# functions: git:hosting:base:*
inherit git-hosting-base

### END: Inherits

### BEGIN: Functions

git:hosting:base:gen_fns "cgit"

### END: Functions

### BEGIN: Constants

declare -g -r -A _CGIT_TMPL_VARS=(
	["SVR"]=CGIT_SVR
	["NS"]=CGIT_NS
	["PROJ"]=CGIT_PROJ
	["DOT_GIT"]=CGIT_DOT_GIT
	["REF"]=CGIT_REF
	["EXT"]=CGIT_SNAP_EXT
)

declare -g -r -A _CGIT_TMPLS=(
	["base"]='${SVR}/${NS:+${NS}/}${PROJ}${DOT_GIT:+.git}/'
	["homepage:gen_url"]="${_CGIT_TMPLS["base"]}"
	["git:gen_url"]="${_CGIT_TMPLS["base"]}"
	["snap:gen_url"]="${_CGIT_TMPLS["base"]}"'snapshot/${PROJ}-${REF}${EXT}'
	["snap:gen_distfile"]='${SVR}--${NS:+${NS}/}${PROJ}--${REF}${EXT}'
)

### END: Constants

### BEGIN: Variables

declare -g -r -- CGIT_SVR="${CGIT_SVR:-"https://git.zx2c4.com"}"
[[ "${CGIT_SVR:(-1)}" == "/" ]] && die "CGIT_SVR ends with a slash"

declare -g -r -- CGIT_NS="${CGIT_NS:-""}"

declare -g -r -- CGIT_PROJ="${CGIT_PROJ:-"${PN}"}"

declare -g -r -- CGIT_DOT_GIT="$(yesno "${CGIT_DOT_GIT}" && echo "yes")"

declare -g -r -- CGIT_REF="${CGIT_REF:-"${PV}"}"

declare -g -r -- CGIT_SNAP_EXT="${CGIT_SNAP_EXT:-".tar.gz"}"

## BEGIN: Readonly variables

git:hosting:base:gen_vars "cgit"

## END: Readonly variables

### END: Variables


_CGIT_ECLASS=1
fi
