# Copyright 2019 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2

# @ECLASS: str-utils.eclass
# @BLURB:

if ! (( _STR_UTILS_ECLASS ))
then

case "${EAPI:-"0"}" in
"7" ) ;;
* ) die "EAPI='${EAPI}' is not supported by '${ECLASS}' eclass" ;;
esac

inherit rindeal


### BEGIN: Functions

str:lstrip() {
	(( ${#} < 1 || ${#} > 2 )) && die
	local -r -- haystack="${1}"
	local -r -- needle="${2:-"[[:space:]]"}"

	local -- result="${haystack}"

	while [[ "${result}" == ${needle}* ]]
	do
		result="${result#${needle}}"
	done

	printf -- "%s" "${result}"
}

str:rstrip() {
	(( ${#} < 1 || ${#} > 2 )) && die
	local -r -- haystack="${1}"
	local -r -- needle="${2:-"[[:space:]]"}"

	local -- result="${haystack}"

	while [[ "${result}" == *${needle} ]]
	do
		result="${result%${needle}}"
	done

	printf -- "%s" "${result}"
}

str:strip() {
	(( ${#} < 1 || ${#} > 2 )) && die
	local -r -- haystack="${1}"
	local -r -- needle="${2:-"[[:space:]]"}"

	str:lstrip "$(str:rstrip "${haystack}" "${needle}")" "${needle}"
}

## Usage: $0 --exp-tmpl-var <VARNAME> --tmpl <STRING> [<VARNAME>=<VALUE> ...]
## Example: $0 --exp-tmpl-var result --tmpl '${HELLO}, ${WORLD}!' HELLO="hello" WORLD="world"
str:tmpl:exp() {
	local -- _tmpl= _exp_tmpl_var=
	local -A _vars=( )

	while (( ${#} > 0 ))
	do
		if [[ "${1}" == "--"* ]] && [[ ${#} -lt 2 || "${2}" == "--"[[:alpha:]]* ]]
		then
			die "Argument '${1}' requires a value, but it wasnt provided"
		fi

		case "${1}" in
		"--tmpl" )
			[[ -n "${_tmpl}" ]] && die "duplicated '${1}' argument"

			_tmpl="${2}"
			shift
			;;
		"--exp-tmpl-var" )
			[[ -n "${_exp_tmpl_var}" ]] && die "duplicated '${1}' argument"

			_exp_tmpl_var="${2}"
			shift
			;;
		[A-Z_][A-Z0-9_]*"="* )
			if ! [[ "${1}" =~ ^[A-Z_][A-Z0-9_]*=.*$ ]]
			then
				die "Invalid argument: '${1}'"
			fi

			local -- _key="${1%%=*}" _val="${1#*=}"

			_vars["${_key}"]="${_val}"
			;;
		* )
			die "Unknown argument: '${1}'"
			;;
		esac

		shift
	done

	[[ -z "${_tmpl}" || -z "${_exp_tmpl_var}" ]] && die

	local -- _key
	for _key in "${!_vars[@]}"
	do
		local -- _val="${_vars["${_key}"]}"

		local -r -- "${_key}=${_val}"
	done

	local -n _exp_tmpl_var_ref="${_exp_tmpl_var}"

	## TODO: make this somewhat safer
	eval "_exp_tmpl_var_ref=\"${_tmpl}\""
}

### END: Functions


declare -g -r -i _STR_UTILS_ECLASS=1
fi
