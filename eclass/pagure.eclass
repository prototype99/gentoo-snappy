# SPDX-FileCopyrightText: 2019  Jan Chren (rindeal)  <dev.rindeal@gmail.com>
#
# SPDX-License-Identifier: GPL-2.0-only

##!
# @ECLASS: pagure.eclass
# @BLURB: Eclass for packages with source code hosted on public Pagure instances
##!

if ! (( _PAGURE_ECLASS ))
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

git:hosting:base:gen_fns "pagure"

### END: Functions

### BEGIN: Constants

declare -g -r -A _PAGURE_TMPL_VARS=(
	["SVR"]=PAGURE_SVR
	["NS"]=PAGURE_NS
	["PROJ"]=PAGURE_PROJ
	["REF"]=PAGURE_REF
	["EXT"]=PAGURE_SNAP_EXT
)

declare -g -r -A _PAGURE_TMPLS=(
	["base"]='${SVR}/${NS:+${NS}/}${PROJ}'
	["homepage:gen_url"]="${_PAGURE_TMPLS["base"]}"
	["git:gen_url"]="${_PAGURE_TMPLS["base"]}.git"
	["snap:gen_url"]="${_PAGURE_TMPLS["base"]}"'/archive/${REF}/${PROJ}-${REF}${EXT}'
	["snap:gen_distfile"]='${SVR}--${NS}/${PROJ}--${REF}${EXT}'
)

### END: Constants

### BEGIN: Variables

declare -g -r -- PAGURE_SVR="${PAGURE_SVR:-"https://pagure.io"}"
[[ "${PAGURE_SVR:(-1)}" == '/' ]] && die "PAGURE_SVR ends with a slash"

declare -g -r -- PAGURE_NS="${PAGURE_NS}"

declare -g -r -- PAGURE_PROJ="${PAGURE_PROJ:-"${PN}"}"

declare -g -r -- PAGURE_REF="${PAGURE_REF:-"${PV}"}"

declare -g -r -- PAGURE_SNAP_EXT="${PAGURE_SNAP_EXT:-".tar.gz"}"

## BEGIN: Readonly variables

git:hosting:base:gen_vars "pagure"

## END: Readonly variables

### END: Variables


_PAGURE_ECLASS=1
fi
