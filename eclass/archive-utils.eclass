# Copyright 2019 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2

# @ECLASS: archive-utils.eclass
# @BLURB:

if ! (( _ARCHIVE_UTILS_ECLASS ))
then

case "${EAPI:-0}" in
'7' ) ;;
* ) die "EAPI='${EAPI}' is not supported by '${ECLASS}' eclass" ;;
esac

inherit rindeal


### BEGIN: Functions

# @FUNCTION: archive:tar:unpack
# @USAGE: [TAR_ARG ...] -- <ARCHIVE> [ARCHIVE ...] <DEST_DIR>
# @DESCRIPTION:
#   Provides simple interface for tar archive unpacking.
#
#   If an archive can be found in ${DISTDIR}, you can specify only a filename instead of a full path.
#   If DEST_DIR doesn't exist, it will be created.
archive:tar:unpack() {
	(( $# < 3 )) && die "Not enough arguments given"

	local -a tar_args=( )
	local -a archs=( )
	local -- dest_dir=

	local -i in_tar_args=1
	while (( $# > 0 ))
	do
		if (( in_tar_args ))
		then
			if [[ "${1}" == '--' ]]
			then
				in_tar_args=0
			else
				tar_args+=( "${1}" )
			fi
		elif (( $# == 1 ))
		then
			if [[ -e "${1}" && ! -d "${1}" ]]
			then
				die "The last argument must be a directory, but it isn't"
			fi

			dest_dir="${1}"
		else
			if [[ "${1}" != *'/' && ! -e "${1}" && -f "${DISTDIR}/${1}" ]]
			then
				debug-print "${FUNCNAME}(): prefixing '${1}' with \$DISTDIR"
				archs+=( "${DISTDIR}/${1}" )
			else
				if [[ ! -f "${1}" ]]
				then
					die "Archive '${1}' doesn't exist or isn't a file"
				fi

				archs+=( "${1}" )
			fi
		fi
		shift
	done

	if [[ ! -d "${dest_dir}" ]]
	then
		mkdir -p "${dest_dir}" || die "Failed to create '${dest_dir}' directory"
	fi

	local -- arch
	for arch in "${archs[@]}"
	do
		printf ">>> Unpacking '%s' to '%s'\n" "${arch##*/}" "${dest_dir}"

		local -a tar_cmd=(
			tar --extract
			--file="${arch}" --directory="${dest_dir}"
			"${tar_args[@]}"
		)
		debug-print "${FUNCNAME[1]}(): ${tar_cmd[*]}"
		"${tar_cmd[@]}" || die "Failed to unpack '${arch}' archive"
	done

	return 0
}


### END: Functions


_ARCHIVE_UTILS_ECLASS=1
fi
