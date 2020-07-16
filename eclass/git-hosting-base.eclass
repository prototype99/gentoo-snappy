# Copyright 2019 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2

# @ECLASS: git-hosting-base.eclass
# @BLURB:

if ! (( _GIT_HOSTING_BASE_ECLASS ))
then

case "${EAPI:-0}" in
'7' ) ;;
* ) die "EAPI='${EAPI}' is not supported by '${ECLASS}' eclass" ;;
esac

inherit rindeal


## functions: str:tmpl:exp
inherit str-utils

## functions: archive:tar:unpack
inherit archive-utils


### BEGIN: Functions

git:hosting:base:gen_fns() {
	(( ${#} != 1 )) && die
	local -r -- _GHB_NS="${1}"
	[[ -z "${_GHB_NS}" ]] && die

	local -r -a fns=(
		{homepage,git,snap}:gen_url
		snap:gen_distfile
		snap:gen_src_uri
		snap:unpack
	)

	local -- fn
	for fn in "${fns[@]}"
	do
	source /dev/stdin <<_EOF_
${_GHB_NS}:${fn}()
{
	local -r -- _GHB_NS="${_GHB_NS}"

	git:hosting:base:_call_namesake "\${@}"
}
_EOF_
	done

	source /dev/stdin <<_EOF_
${_GHB_NS}:src_unpack() {
	${_GHB_NS}:snap:unpack "\${DISTDIR}/\${${_GHB_NS^^}_SNAP_DISTFILE}" "\${WORKDIR}/\${P}"
}
_EOF_
}

git:hosting:base:gen_vars() {
	(( ${#} != 1 )) && die
	local -r -- _GHB_NS="${1}"
	[[ -z "${_GHB_NS}" ]] && die
	local -r var_prefix="${_GHB_NS^^}"

	source /dev/stdin <<_EOF_
declare -g -- ${var_prefix}_SNAP_URL= ${var_prefix}_SNAP_DISTFILE=
${_GHB_NS}:snap:gen_src_uri --url-var ${var_prefix}_SNAP_URL --distfile-var ${var_prefix}_SNAP_DISTFILE
readonly ${var_prefix}_SNAP_URL ${var_prefix}_SNAP_DISTFILE

declare -g -r -- ${var_prefix}_SRC_URI="\${${var_prefix}_SNAP_URL} -> \${${var_prefix}_SNAP_DISTFILE}"

declare -g -- ${var_prefix}_HOMEPAGE=
${_GHB_NS}:homepage:gen_url --url-var ${var_prefix}_HOMEPAGE
readonly ${var_prefix}_HOMEPAGE
_EOF_
}

git:hosting:base:_call_namesake() {
	[[ -z "${_GHB_NS}" ]] && die
	git:hosting:base:"${FUNCNAME[1]#"${_GHB_NS}:"}" "${@}"
}

git:hosting:base:_get_tmpl() {
	(( ${#} > 1 )) && die
	[[ -z "${_GHB_NS}" ]] && die

	local -- tmpl_name
	if (( ${#} == 1 ))
	then
		[[ -z "${1}" ]] && die
		tmpl_name="${1}"
	else
		tmpl_name="${FUNCNAME[1]#"git:hosting:base:"}"
	fi

	local -r -n _tmpls_var_ref="_${_GHB_NS^^}_TMPLS"
	local -r -- tmpl="${_tmpls_var_ref["${tmpl_name}"]}"

	printf -- "%s" "${tmpl}"
}

git:hosting:base:_gen_default_tmpl_vars() {
	(( ${#} != 1 )) && die
	[[ -z "${_GHB_NS}" ]] && die

	local -n dst_var_ref="${1}"

	local -r -- tmpl_vars_varname="_${_GHB_NS^^}_TMPL_VARS"
	[[ "$(declare -p "${tmpl_vars_varname}")" != "declare -A"* ]] && die

	local -r -n tmpl_vars_ref="${tmpl_vars_varname}"

	local -- var valsrc val
	for var in "${!tmpl_vars_ref[@]}"
	do
		valsrc="${tmpl_vars_ref["${var}"]}"
		val="${!valsrc}"
		dst_var_ref+=( "${var}=${val}" )
	done
}

git:hosting:sanitize_filename() {
	(( ${#} != 1 )) && die "Invalid number of arguments supplied, got '${#}' expected '1'"

	local -r -- filename_arg="${1}"

	local -- filename="${filename_arg}"
	local -- regex

	## try to remove scheme part altogether
	filename="${filename//"ftp://"/}"
	filename="${filename//"http://"/}"
	filename="${filename//"https://"/}"

	## strip leading slashes
	while [[ "${filename}" == *"--/"* ]]
	do
		filename="${filename//"--/"/--}"
	done

	## strip trailing slashes
	while [[ "${filename}" == *"/--"* ]]
	do
		filename="${filename//"/--"/--}"
	done

	## replace all non-permitted characters
	regex='[^a-zA-Z0-9\._-]'
	while [[ "${filename}" =~ ${regex} ]]
	do
		filename="${filename//${BASH_REMATCH[0]}/_}"
	done

	debug-print "${FUNCNAME[0]}: '${filename_arg}' => '${filename}'"

	(( ${#filename} >= 255 )) && die "Filename too long: len('${filename}') => ${#filename}"

	printf "%s" "${filename}"
}

git:hosting:snap:unpack() {
	archive:tar:unpack --strip-components=1 -- "${@}"
}

git:hosting:base:_gen_url() {
	[[ -z "${_GHB_NS}" ]] && die
	[[ -z "${_GHB_TMPL}" ]] && die

	local -r -- tmpl="${_GHB_TMPL}"

	local -a default_vars=()
	git:hosting:base:_gen_default_tmpl_vars default_vars

	local -a args=( )

	while (( ${#} > 0 ))
	do
		case "${1}" in
		"--url-var" )
			args+=( "--exp-tmpl-var" )
			;;
		* )
			args+=( "${1}" )
			;;
		esac

		shift
	done

	str:tmpl:exp "${default_vars[@]}" "${args[@]}" --tmpl "${tmpl}"
}

git:hosting:base:_gen_distfile() {
	[[ -z "${_GHB_NS}" ]] && die
	[[ -z "${_GHB_TMPL}" ]] && die

	local -- tmpl="${_GHB_TMPL}"
	tmpl="\$(git:hosting:sanitize_filename \"${tmpl}\")"
	readonly tmpl

	local -a default_vars=()
	git:hosting:base:_gen_default_tmpl_vars default_vars

	local -a args=( )

	while (( ${#} > 0 ))
	do
		case "${1}" in
		"--distfile-var" )
			args+=( "--exp-tmpl-var" )
			;;
		* )
			args+=( "${1}" )
			;;
		esac

		shift
	done

	str:tmpl:exp "${default_vars[@]}" "${args[@]}" --tmpl "${tmpl}"
}

git:hosting:base:homepage:gen_url() {
	local -r -- _GHB_TMPL="$(git:hosting:base:_get_tmpl)"
	git:hosting:base:_gen_url "${@}"
}
git:hosting:base:git:gen_url() {
	local -r -- _GHB_TMPL="$(git:hosting:base:_get_tmpl)"
	git:hosting:base:_gen_url "${@}"
}
git:hosting:base:snap:gen_url() {
	local -r -- _GHB_TMPL="$(git:hosting:base:_get_tmpl)"
	git:hosting:base:_gen_url "${@}"
}
git:hosting:base:snap:gen_distfile() {
	local -r -- _GHB_TMPL="$(git:hosting:base:_get_tmpl)"
	git:hosting:base:_gen_distfile "${@}"
}

git:hosting:base:snap:gen_src_uri() {
	[[ -z "${_GHB_NS}" ]] && die

	local -- _url_var= _distfile_var=
	local -a _args=( )

	while (( ${#} > 0 ))
	do
		case "${1}" in
		"--url-var" | "--distfile-var" )
			if [[ ${#} -lt 2 || -z "${2}" || "${2}" == "--"* ]]
			then
				die "'${1}' value not provided"
			fi

			case "${1}" in
			"--url-var" ) _url_var="${2}" ;;
			"--distfile-var" ) _distfile_var="${2}" ;;
			esac

			shift
			;;
		* )
			_args+=( "${1}" )
			;;
		esac

		shift
	done
	[[ -z "${_url_var}" ]] && die
	[[ -z "${_distfile_var}" ]] && die

	local -- _fn_prefix="${_GHB_NS}"

	"${_fn_prefix}":snap:gen_url      --url-var      "${_url_var}"      "${_args[@]}"
	"${_fn_prefix}":snap:gen_distfile --distfile-var "${_distfile_var}" "${_args[@]}"
}

git:hosting:base:snap:unpack() {
	git:hosting:snap:unpack "${@}"
}

### END: Functions


# prefer their CDN over Gentoo mirrors
RESTRICT+=" primaryuri"


_GIT_HOSTING_BASE_ECLASS=1
fi
