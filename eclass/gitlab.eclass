# SPDX-FileCopyrightText: 2019  Jan Chren (rindeal)  <dev.rindeal@gmail.com>
#
# SPDX-License-Identifier: GPL-2.0-only

# @ECLASS: gitlab.eclass
# @BLURB: Eclass for packages with source code hosted on public GitLab instances

if ! (( _GITLAB_ECLASS ))
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

git:hosting:base:gen_fns "gitlab"

### END: Functions

### BEGIN: Constants

declare -g -r -A _GITLAB_TMPL_VARS=(
	["SVR"]=GITLAB_SVR
	["NS"]=GITLAB_NS
	["PROJ"]=GITLAB_PROJ
	["REF"]=GITLAB_REF
	["EXT"]=GITLAB_SNAP_EXT
)

declare -g -r -A _GITLAB_TMPLS=(
	["base"]='${SVR}/${NS}/${PROJ}'
	["homepage:gen_url"]="${_GITLAB_TMPLS["base"]}"
	["git:gen_url"]="${_GITLAB_TMPLS["base"]}.git"
	["snap:gen_url"]="${_GITLAB_TMPLS["base"]}"'/-/archive/${REF}/${PROJ}-${REF}${EXT}'
	["snap:gen_distfile"]='${SVR}--${NS}/${PROJ}--${REF}${EXT}'
)

### END: Constants

### BEGIN: Variables

declare -g -r -- GITLAB_SVR="${GITLAB_SVR:-"https://gitlab.com"}"
[[ "${GITLAB_SVR:(-1)}" == '/' ]] && die "GITLAB_SVR ends with a slash"

declare -g -r -- GITLAB_NS="${GITLAB_NS:-"${PN}"}"

declare -g -r -- GITLAB_PROJ="${GITLAB_PROJ:-"${PN}"}"

declare -g -r -- GITLAB_REF="${GITLAB_REF:-"${PV}"}"

declare -g -r -- GITLAB_SNAP_EXT="${GITLAB_SNAP_EXT:-".tar.bz2"}"

## BEGIN: Readonly variables

git:hosting:base:gen_vars "gitlab"

## END: Readonly variables

### END: Variables


_GITLAB_ECLASS=1
fi
