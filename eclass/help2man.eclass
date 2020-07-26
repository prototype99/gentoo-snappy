# Copyright 2018-2019 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2

# @ECLASS: help2man.eclass


if ! (( _HELP2MAN_ECLASS ))
then

case "${EAPI:-0}" in
"6" | "7" ) ;;
* ) die "Unsupported EAPI='${EAPI}' for '${ECLASS}'" ;;
esac

inherit rindeal


DEPEND="sys-apps/help2man"


newhelp2man()
{
	debug-print "${ECLASS}: ${FUNCNAME} ${*}"
	local -r -- binpath="${1}" ; shift
	local -r -- manname="${1}" ; shift
	local -- tmpfile="$(mktemp --suffix=".${FUNCNAME}")"
	local -- bindirname="$(dirname "${binpath}")"

	local -a default_opts=()

	(( H2M_NO_DEFAULT_NAME           )) || default_opts+=( --name="${PN}"           )
	(( H2M_NO_DEFAULT_VERSION_STRING )) || default_opts+=( --version-string="${PV}" )
	(( H2M_NO_DEFAULT_NO_INFO        )) || default_opts+=( --no-info                )
	(( H2M_NO_DEFAULT_DISCARD_STDERR )) || default_opts+=( --no-discard-stderr      )
	(( H2M_NO_DEFAULT_HELP_OPTION    )) || default_opts+=( --help-option="-h"       )

	local -a help2man=(
		help2man

		"${default_opts[@]}"
		"${HELP2MAN_OPTS[@]}"
		--output="${tmpfile}"

		"$(basename "${binpath}")"
	)

	debug-print "PATH=${bindirname}:\$PATH" "${help2man[@]}"
	PATH="${bindirname}:${PATH}" "${help2man[@]}" || die

	newman "${tmpfile}" "${manname}"
}

dohelp2man()
{
	newhelp2man "${1}" "$(basename "${1}").1"
}


_HELP2MAN_ECLASS=1
fi
