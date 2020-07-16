# SPDX-FileCopyrightText: 2019  Jan Chren (rindeal)  <dev.rindeal@gmail.com>
#
# SPDX-License-Identifier: GPL-2.0-only

##!
# @ECLASS: github.eclass
# @BLURB: Eclass for packages with source code hosted on public GitHub and GitHub-clones (Gitea/Gogs) instances
##!

if ! (( _GITHUB_ECLASS ))
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

git:hosting:base:gen_fns "github"

### END: Functions

### BEGIN: Constants

declare -g -r -A _GITHUB_TMPL_VARS=(
	["SVR"]=GITHUB_SVR
	["NS"]=GITHUB_NS
	["PROJ"]=GITHUB_PROJ
	["REF"]=GITHUB_REF
	["EXT"]=GITHUB_SNAP_EXT
)

declare -g -r -A _GITHUB_TMPLS=(
	["base"]='${SVR}/${NS}/${PROJ}'
	["homepage:gen_url"]="${_GITHUB_TMPLS["base"]}"
	["git:gen_url"]="${_GITHUB_TMPLS["base"]}.git"
	["snap:gen_url"]="${_GITHUB_TMPLS["base"]}"'/archive/${REF}${EXT}'
	["snap:gen_distfile"]='${SVR}--${NS}/${PROJ}--${REF}${EXT}'
)

### END: Constants

### BEGIN: Variables

declare -g -r -- GITHUB_SVR="${GITHUB_SVR:-"https://github.com"}"
[[ "${GITHUB_SVR:(-1)}" == '/' ]] && die "GITHUB_SVR ends with a slash"

declare -g -r -- GITHUB_NS="${GITHUB_NS:-"${PN}"}"

declare -g -r -- GITHUB_PROJ="${GITHUB_PROJ:-"${PN}"}"

declare -g -r -- GITHUB_REF="${GITHUB_REF:-"${PV}"}"

declare -g -r -- GITHUB_SNAP_EXT="${GITHUB_SNAP_EXT:-".tar.gz"}"

## BEGIN: Readonly variables

git:hosting:base:gen_vars "github"

## END: Readonly variables

### END: Variables


_GITHUB_ECLASS=1
fi
