# Copyright 2016-2017,2019 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2

# @ECLASS: git-hosting.eclass
# @MAINTAINER:
# Jan Chren (rindeal) <dev.rindeal+gentoo@gmail.com>
# @BLURB: Support eclass for packages hosted on online git hosting services like GitHub

if [[ -z "${_RINDEAL_GH_ECLASS}" ]]
then

case "${EAPI:-0}" in
6 | 7 ) ;;
* ) die "Unsupported EAPI='${EAPI}' for '${ECLASS}'" ;;
esac


### BEGIN Constants

declare -g -r -a -- _GH_AVAILABLE_PROVIDERS=(
	bitbucket
	github
	gitlab
	kernel
	freedesktop
)

### END Constants


### BEGIN Base classes

_gh_provider:bitbucket:base_url() { printf '%s' 'bitbucket.org' ; }
_gh_provider:bitbucket:snap_ext() { printf '%s' '.tar.bz2'      ; }
_gh_provider:bitbucket:snap_url_tail() {
	(( $# != 1 )) && die

	local -r -- ref="${1}"
	local -r -- snap_ext="$(_gh_provider:bitbucket:snap_ext)"

	printf '%s' "get/${ref}${snap_ext}"
}


_gh_provider:github:base_url() { printf '%s' 'github.com' ; }
_gh_provider:github:snap_ext() { printf '%s' '.tar.gz'    ; }
_gh_provider:github:snap_url_tail() {
	(( $# != 1 )) && die

	local -r -- ref="${1}"
	local -r -- snap_ext="$(_gh_provider:github:snap_ext)"

	printf '%s' "archive/${ref}${snap_ext}"
}


_gh_provider:gitlab:base_url() { printf '%s' 'gitlab.com' ; }
_gh_provider:gitlab:snap_ext() { printf '%s' '.tar.bz2'   ; }
_gh_provider:gitlab:snap_url_tail() {
	(( $# != 1 )) && die

	local -r -- ref="${1}"
	local -r -- snap_ext="$(_gh_provider:gitlab:snap_ext)"

	printf '%s' "repository/archive${snap_ext}?ref=${ref}"
}


_gh_provider:kernel:base_url() { printf '%s' 'git.kernel.org/pub/scm' ; }
_gh_provider:kernel:snap_ext() { printf '%s' '.tar.gz'                ; }
_gh_provider:kernel:snap_url_tail() {
	(( $# != 1 )) && die

	local -r -- ref="${1}"
	local -r -- snap_ext="$(_gh_provider:kernel:snap_ext)"

	printf '%s' "snapshot/${ref}${snap_ext}"
}


_gh_provider:freedesktop:base_url() { printf '%s' 'cgit.freedesktop.org' ; }
_gh_provider:freedesktop:snap_ext() { printf '%s' '.tar.bz2'             ; }
_gh_provider:freedesktop:snap_url_tail() {
	(( $# != 1 )) && die

	local -r -- ref="${1}"
	local -r -- snap_ext="$(_gh_provider:freedesktop:snap_ext)"

	printf '%s' "snapshot/${ref}${snap_ext}"
}


_gh_provider:gentoo:base_url() { printf '%s' 'gitweb.gentoo.org' ; }
_gh_provider:gentoo:snap_ext() { printf '%s' '.tar.bz2'          ; }
_gh_provider:gentoo:snap_url_tail() {
	(( $# != 1 )) && die

	local -r -- ref="${1}"
	local -r -- snap_ext="$(_gh_provider:gentoo:snap_ext)"

	printf '%s' "snapshot/${ref}${snap_ext}"
}

### END Base classes


### BEGIN Functions

_gh_provider:exists() {
	(( $# != 1 )) && die

	local -r -- provider="${1}"

	local e
	for e in "${_GH_AVAILABLE_PROVIDERS[@]}"; do
		[[ "${e}" == "${provider}" ]] && return 0
	done

	return 1
}

##
# @FUNCTION:	_gh_parse_rn
# @PRIVATE
# @USAGE:		$0 "${rn}" provider path repo
# @DESCRIPTION: parses RN into its components
##
_gh_parse_rn() {
	(( $# != 4 )) && die "${FUNCNAME}: Not enough arguments provided"

	local -r -- rn="${1}" ; shift
	local -n -- provider_nref="${1}" ; shift
	local -n -- path_nref="${1}" ; shift
	local -n -- repo_nref="${1}" ; shift

	# TODO: change it to allow for spaces in components
	local -r -a rn_a=( ${rn//':'/ } )

	case "${#rn_a[*]}" in
	'3' )
		repo_nref="${rn_a[2]}"
		;&
	'2' )
		path_nref="${rn_a[1]}"
		;&
	'1' )
		provider_nref="${rn_a[0]}"
		;;
	* )
		die
		;;
	esac

	return 0
}

##
# @FUNCTION:	_gh_gen_repo_url
# @PRIVATE
# @USAGE:		$0 "${provider}" "${path}" "${repo}" repo_url
# @DESCRIPTION: Generate base URL of the repository. Can be used as a homepage.
##
_gh_gen_repo_url() {
	(( $# != 4 )) && die "${FUNCNAME}: Not enough arguments provided"

	local -r -- provider="${1}" ; shift
	local -r -- path="${1}" ; shift
	local -r -- repo="${1}" ; shift
	local -n -- repo_url_nref="${1}" ; shift

	local -r -- base_url="$(_gh_provider:${provider}:base_url)"

	repo_url_nref="https://${base_url}${path:+"/${path}"}${repo:+"/${repo}"}"

	return 0
}


##
# @FUNCTION:	git-hosting_gen_live_url
# @USAGE:		$0 "${gh_rn}" live_url
# @DESCRIPTION: Generate URL for git
##
git-hosting_gen_live_url() {
	(( $# != 2 )) && die "${FUNCNAME}: Not enough arguments provided"

	local -r -- rn="${1}" ; shift
	local -n -- live_url_nref="${1}" ; shift

	local -- provider user repo
	_gh_parse_rn "${rn}" provider user repo
	readonly provider user repo

	local -- repo_url
	_gh_gen_repo_url "${provider}" "${user}" "${repo}" repo_url
	readonly repo_url

	live_url_nref="${repo_url%'.git'}.git"
}

##
# @FUNCTION:	git-hosting_gen_snapshot_url
# @USAGE:		$0 "${rn}" "${ref}" snapshot_url distfile
# @DESCRIPTION: Generate snapshot URL
##
git-hosting_gen_snapshot_url() {
	(( $# != 4 )) && die

	local -r -- rn="${1}" ; shift
	local -r -- ref="${1}" ; shift
	local -n -- snapshot_url_nref="${1}" ; shift
	local -n -- distfile_nref="${1}" ; shift

	local -- provider path repo
	_gh_parse_rn "${rn}" provider path repo
	readonly provider path repo

	local -- repo_url
	_gh_gen_repo_url "${provider}" "${path}" "${repo}" repo_url
	readonly repo_url

	local -r -- snap_url_tail="$( _gh_provider:${provider}:snap_url_tail "${ref}" )"

	local -- _distfile_base="${provider}--${path}--${repo}--${ref}"
	_distfile_base="${_distfile_base//'/'/_}"

	snapshot_url_nref="${repo_url}/${snap_url_tail}"
	distfile_nref="${_distfile_base}$( _gh_provider:${provider}:snap_ext )"
}

##
# @FUNCTION:	git-hosting_unpack
##
git-hosting_unpack() {
	(( $# != 2 )) && die
	local -r -- unpack_from="${1}"
	# do not use '${S}' for 'unpack_to' as user might overwrite 'S' leading to a wrong behaviour
	local -r -- unpack_to="${2}"

	printf ">>> Unpacking '%s' to '%s'\n" "${unpack_from##*/}" "${unpack_to}"
	mkdir -p "${unpack_to}" || die "Failed to create '${unpack_to}' directory"
	local tar=( tar --extract
		--strip-components=1
		--file="${unpack_from}" --directory="${unpack_to}" )
	"${tar[@]}" || die "Failed to extract '${unpack_from}' archive"

	## filter 'unpack_from' from 'A'
	local f new_a_a=()
	for f in ${A} ; do
		if [[ "${f}" != "${unpack_from##*/}" ]] ; then
			new_a_a+=( "${f}" )
		fi
	done
	A="${new_a_a[@]}"

	return 0
}

### END Functions


### BEGIN Variables

##
# @ECLASS-VARIABLE: GH_RN
# @DEFAULT_UNSET
# @DESCRIPTION:
# Resource name. A string in the format:
#
#      <provider>[[:<path>][:<repository_name>]]
#
# Default <path> and <repository_name> is ${PN}.
##
[[ -z "${GH_RN}" ]] && die "GH_RN must be set to a non-empty value"

##
# @ECLASS-VARIABLE: GH_PROVIDER
# @READONLY
# @DEFAULT_UNSET
# @DESCRIPTION:
# Contains the first part of GH_RN - the git hosting provider.
# Currently one of 'github', 'gitlab', 'bitbucket', 'kernel'.
##
GH_PROVIDER=

##
# @ECLASS-VARIABLE: _GH_PATH
# @READONLY
# @PRIVATE
# @DEFAULT: ${PN}
# @DESCRIPTION:
# Contains the second part of GH_RN - the path.
##
_GH_PATH="${PN}"

##
# @ECLASS-VARIABLE: GH_REPO
# @READONLY
# @DEFAULT: ${PN}
# @DESCRIPTION:
# Contains the third part of GH_RN - the repository name.
##
GH_REPO="${PN}"

_gh_parse_rn "${GH_RN}" GH_PROVIDER _GH_PATH GH_REPO

case "${GH_PROVIDER}" in
'kernel' )
	# make sure `.git` is appended
	GH_REPO="${GH_REPO%'.git'}.git"
	# append `PN` if requested
	[[ -z "${_GH_PATH##*/}" ]] && _GH_PATH+="${PN}"
	;;
esac

declare -g -r -- GH_PROVIDER _GH_PATH GH_REPO

##
# @ECLASS-VARIABLE: _GH_RN
# @READONLY
# @PRIVATE
# @DESCRIPTION:
# Expanded form of GH_RN, always has all three components.
##
declare -g -r -- _GH_RN="${GH_PROVIDER}:${_GH_PATH}:${GH_REPO}"

##
# @ECLASS-VARIABLE: GH_FETCH_TYPE
# @DEFAULT: 'snapshot', for versions containing '9999' defaults to 'live'
# @DESCRIPTION:
# Defines if fetched from git ("live") or archive ("snapshot") or eclass
# shouldn't handle fetching at all ("manual").
##
if [[ -z "${GH_FETCH_TYPE}" ]] ; then
	if [[ "${PV}" == *9999* ]] ; then
		GH_FETCH_TYPE='live'
	else
		GH_FETCH_TYPE='snapshot'
	fi
fi
declare -g -r -- GH_FETCH_TYPE

##
# @ECLASS-VARIABLE: GH_REF
# @DEFAULT: for 'snapshot', "${PV}"
# @DESCRIPTION:
# Tag/commit/git_ref (except branches) that is fetched from git hosting provider.
##
if [[ -z "${GH_REF}" ]] ; then
	case "${GH_FETCH_TYPE}" in
	'snapshot' )
		# a research conducted on April 2016 among the first 700 repos with >10000 stars on GitHub shows:
		# - no tags: 158
		# - `v` prefix: 350
		# - no prefix: 192
		GH_REF="${PV}"
		;;
	'live' | 'manual' )
		:
		;;
	* )
		die "Unsupported fetch type: '${GH_FETCH_TYPE}'"
		;;
	esac
fi
declare -g -r -- GH_REF

##
# @ECLASS-VARIABLE: _GH_DOMAIN
# @PRIVATE
# @READONLY
# @DESCRIPTION:
# Base
##
declare -g -r -- _GH_DOMAIN="$(_gh_provider:${GH_PROVIDER}:base_url)"

##
# @ECLASS-VARIABLE: GH_REPO_URL
# @READONLY
# @DEFAULT: "https://${_GH_BASE_URL}/${_GH_PATH}/${GH_REPO}"
# @DESCRIPTION:
# Base uri of the repo
##
_gh_gen_repo_url "${GH_PROVIDER}" "${_GH_PATH}" "${GH_REPO}" GH_REPO_URL
declare -g -r -- GH_REPO_URL

##
# @ECLASS-VARIABLE: GH_HOMEPAGE
# @READONLY
# @DEFAULT: "${GH_REPO_URL}"
# @DESCRIPTION:
# Homepage of the repository hosted by the git hosting provider/
##
declare -g -r -- GH_HOMEPAGE="${GH_REPO_URL}"


case "${GH_FETCH_TYPE}" in
'snapshot' )
	git-hosting_gen_snapshot_url "${_GH_RN}" "${GH_REF}" _GH_SNAPSHOT_SRC_URI _GH_DISTFILE
	declare -g -r -- _GH_SNAPSHOT_SRC_URI _GH_DISTFILE
	;;
'live' | 'manual' )
	:
	;;
* )
	die "Unsupported fetch type: '${GH_FETCH_TYPE}'"
	;;
esac

RESTRICT+=" mirror"

### END Variables


### BEGIN Inherits

case "${GH_FETCH_TYPE}" in
'live' )
	[[ -z "${EGIT_REPO_URI}" ]] && \
		git-hosting_gen_live_url "${_GH_RN}" EGIT_REPO_URI
	[[ -n "${GH_REF}" && -z "${EGIT_COMMIT}" ]] && \
		EGIT_COMMIT="${GH_REF}"
	[[ -z "${EGIT_CLONE_TYPE}" ]] && \
		EGIT_CLONE_TYPE="shallow"

	inherit git-r3
	;;
'snapshot' | 'manual' )
	:
	;;
*)
	die "Unsupported fetch type: '${GH_FETCH_TYPE}'"
	;;
esac

### END Inherits


### BEGIN Portage variables

# set SRC_URI only for 'snapshot' GH_FETCH_TYPE
case "${GH_FETCH_TYPE}" in
'snapshot' )
	SRC_URI="${_GH_SNAPSHOT_SRC_URI} -> ${_GH_DISTFILE}"
	;;
'live' | 'manual' )
	:
	;;
* )
	die "Unsupported fetch type: '${GH_FETCH_TYPE}'"
	;;
esac

: "${HOMEPAGE:="${GH_HOMEPAGE}"}"

# prefer their CDN over Gentoo mirrors
RESTRICT="${RESTRICT} primaryuri"

### END Portage variables


# debug-print summary
if [[ -n "${EBUILD_PHASE_FUNC}" && "${EBUILD_PHASE_FUNC}" == 'pkg_setup' ]] ; then
	debug-print "${ECLASS}: -- vardump --"
	for _v in $(compgen -A variable) ; do
		if [[ "${_v}" == "GH_"* || "${_v}" == "EGIT_"* ]] ; then
			debug-print "${ECLASS}: ${_v}='${!_v}'"
		fi
	done
	debug-print "${ECLASS}: ----"
	unset _v
fi


### BEGIN Exported functions

EXPORT_FUNCTIONS src_unpack

##
# @FUNCTION: git-hosting_src_unpack
# @DESCRIPTION:
# Handles unpacking of special source files, like git snapshots, live git repos, ...
#
# Please note that if GH_FETCH_TYPE=~(live|snapshot) this function won't unpack files from SRC_URI
# other than those it added itself, additionally, upon execution it filters them out of '${A}' variable, so
# that you can than loop through '${A}' safely and unpack the rest yourself or just call default().
##
git-hosting_src_unpack() {
	debug-print-function "${FUNCNAME}"

	case "${GH_FETCH_TYPE}" in
	'live' )
		git-r3_src_unpack
		;;
	'snapshot' )
		git-hosting_unpack "${DISTDIR}/${_GH_DISTFILE}" "${WORKDIR}/${P}"
		;;
	'manual' )
		default
		;;
	* )
		die
		;;
	esac
}

### END Exported functions


_RINDEAL_GH_ECLASS=1
fi
