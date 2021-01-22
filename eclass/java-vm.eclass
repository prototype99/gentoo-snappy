# Copyright 2017 Obsidian-Studios, Inc.
# Distributed under the terms of the GNU General Public License v2

# Based on eclass
# Copyright 1999-2019 Gentoo Authors

# @ECLASS: java-vm.eclass
# @MAINTAINER:
# William L. Thomson Jr. <wlt@o-sinc.com>
# @SUPPORTED_EAPIS: 6 7
# @BLURB: Java Virtual Machine eclass
# @DESCRIPTION:
# This eclass provides functionality which assists with installing
# virtual machines, and ensures that they are recognized by jem.

case ${EAPI:-0} in
	6|7) ;;
	*) die "EAPI=${EAPI} is not supported" ;;
esac

inherit multilib pax-utils prefix xdg-utils

EXPORT_FUNCTIONS pkg_setup pkg_postinst pkg_prerm pkg_postrm

RDEPEND="dev-java/jem"
DEPEND="${RDEPEND}"

# @ECLASS-VARIABLE: JAVA_VM_CONFIG_DIR
# @INTERNAL
# @DESCRIPTION:
# Where to place the vm env file.
JAVA_VM_CONFIG_DIR="/etc/jem/vms.d"

# @ECLASS-VARIABLE: JAVA_VM_DIR
# @INTERNAL
# @DESCRIPTION:
# Base directory for vm links.
JAVA_VM_DIR="/usr/lib/jvm"

# @ECLASS-VARIABLE: JAVA_VM_BUILD_ONLY
# @DESCRIPTION:
# Set to YES to mark a vm as build-only.
JAVA_VM_BUILD_ONLY="${JAVA_VM_BUILD_ONLY:-FALSE}"


# @FUNCTION: java-vm_pkg_setup
# @DESCRIPTION:
# default pkg_setup
#
# Initialize vm handle.
java-vm_pkg_setup() {
	VMHANDLE=${PN}
	[[ "${SLOT}" != "0" ]] && VMHANDLE+="-${SLOT}"
}


# @FUNCTION: java-vm_pkg_postinst
# @DESCRIPTION:
# default pkg_postinst
#
# Set the generation-2 system VM, if it isn't set or the setting is
# invalid. Also update mime database.
java-vm_pkg_postinst() {
	if [[ ! -L "${EROOT}/etc/jem/vm" ]]; then
		java_set_default_vm_
	else
		local vm vm_path

		vm_path=$(readlink "${EROOT}/etc/jem/vm")
		vm=$(basename "${ROOT}${vm_path}")
		if [[ ! -L "${EROOT}${JAVA_VM_DIR}/${vm}" ]]; then
			java_set_default_vm_
		fi
	fi

	xdg_desktop_database_update
}


# @FUNCTION: java-vm_pkg_prerm
# @DESCRIPTION:
# default pkg_prerm
#
# Warn user if removing system-vm.
java-vm_pkg_prerm() {
	if [[ "$(JEM_VM="" jem -f 2>/dev/null)" == "${VMHANDLE}" ]] && \
		[[ -z "${REPLACED_BY_VERSION}" ]]; then
		ewarn "It appears you are removing your system-vm!"
		ewarn "Please run jem -L to list available VMs,"
		ewarn "then use jem -S to set a new system-vm!"
	fi
}


# @FUNCTION: java-vm_pkg_postrm
# @DESCRIPTION:
# default pkg_postrm
#
# Update mime database.

java-vm_pkg_postrm() {
	xdg_desktop_database_update
}


# @FUNCTION: java_set_default_vm_
# @INTERNAL
# @DESCRIPTION:
# Set system-vm.

java_set_default_vm_() {
	jem --set-system-vm="${VMHANDLE}"

	einfo " ${P} set as the default system-vm."
}


# @FUNCTION: java-vm_install-env
# @DESCRIPTION:
#
# Installs a Java VM environment file. The source can be specified but
# defaults to ${FILESDIR}/${VMHANDLE}.env.sh.
#
# Environment variables within this file will be resolved. You should
# escape the $ when referring to variables that should be resolved later
# such as ${JAVA_HOME}. Subshells may be used but avoid using double
# quotes. See icedtea-bin.env.sh for a good example.

java-vm_install-env() {
	debug-print-function ${FUNCNAME} $*
	local env_file java_home source_env_file

	source_env_file="${1-${FILESDIR}/${VMHANDLE}.env}"
	if [[ ! -f ${source_env_file} ]]; then
		die "Unable to find the env file: ${source_env_file}"
	fi

	env_file="${ED}${JAVA_VM_CONFIG_DIR}/${VMHANDLE}"
	dodir "${JAVA_VM_CONFIG_DIR}"
	sed \
		-e "s/@P@/${P}/g" \
		-e "s/@PN@/${PN}/g" \
		-e "s/@PV@/${PV}/g" \
		-e "s/@SLOT@/${SLOT}/g" \
		-e "s/@LIBDIR@/$(get_libdir)/g" \
		< "${source_env_file}" \
		> "${env_file}" || die "sed failed"

	(
		echo "VMHANDLE=\"${VMHANDLE}\""
		echo "BUILD_ONLY=\"${JAVA_VM_BUILD_ONLY}\""
		[[ ${JAVA_PROVIDE} ]] && \
			echo "PROVIDES=\"${JAVA_PROVIDE}\"" || true
	) >> "${env_file}" || die "Failed to append to Java env file"

	eprefixify ${env_file}

	java_home=$(unset JAVA_HOME; source "${env_file}"; echo ${JAVA_HOME})
	[[ -z ${java_home} ]] && die "JAVA_HOME not defined in ${env_file}"

	# Make the symlink
	dodir "${JAVA_VM_DIR}"
	dosym "${java_home#${EPREFIX}}" "${JAVA_VM_DIR}/${VMHANDLE}"
}


# @FUNCTION: java-vm_set-pax-markings
# @DESCRIPTION:
# Set PaX markings on all JDK/JRE executables to allow code-generation on
# the heap by the JIT compiler.
#
# The markings need to be set prior to the first invocation of the the freshly
# built / installed VM. Be it before creating the Class Data Sharing archive or
# generating cacerts. Otherwise a PaX enabled kernel will kill the VM.
# Bug #215225 #389751
#
# @CODE
#   Parameters:
#     $1 - JDK/JRE base directory.
#
#   Examples:
#     java-vm_set-pax-markings "${S}"
#     java-vm_set-pax-markings "${ED}"/opt/${P}
# @CODE

java-vm_set-pax-markings() {
	debug-print-function ${FUNCNAME} "$*"
	[[ $# -ne 1 ]] && die "${FUNCNAME}: takes exactly one argument"
	[[ ! -f "${1}"/bin/java ]] \
		&& die "${FUNCNAME}: argument needs to be JDK/JRE base directory"

	local executables=( "${1}"/bin/* )
	[[ -d "${1}"/jre ]] && executables+=( "${1}"/jre/bin/* )

	# Usually disabling MPROTECT is sufficient.
	local pax_markings="m"
	# On x86 for heap sizes over 700MB disable SEGMEXEC and PAGEEXEC as well.
	use x86 && pax_markings+="sp"

	pax-mark ${pax_markings} $(list-paxables "${executables[@]}")
}


# @FUNCTION: java-vm_revdep-mask
# @DESCRIPTION:
# Installs a revdep-rebuild control file which SEARCH_DIR_MASK set to the path
# where the VM is installed. Prevents pointless rebuilds - see bug #177925.
# Also gives a notice to the user.
#
# @CODE
#   Parameters:
#     $1 - Path of the VM (defaults to /opt/${P} if not set)
#
#   Examples:
#     java-vm_revdep-mask
#     java-vm_revdep-mask /path/to/jdk/
#
# @CODE

java-vm_revdep-mask() {
	debug-print-function ${FUNCNAME} "$*"

	local VMROOT="${1-"${EPREFIX}"/opt/${P}}"

	dodir /etc/revdep-rebuild
	echo "SEARCH_DIRS_MASK=\"${VMROOT}\"" >> "${ED}/etc/revdep-rebuild/61-${VMHANDLE}" \
		 || die "Failed to write revdep-rebuild mask file"
}


# @FUNCTION: java-vm_sandbox-predict
# @DESCRIPTION:
# Install a sandbox control file. Specified paths won't cause a sandbox
# violation if opened read write but no write takes place. See bug 388937#c1
#
# @CODE
#   Examples:
#     java-vm_sandbox-predict /dev/random /proc/self/coredump_filter
# @CODE

java-vm_sandbox-predict() {
	debug-print-function ${FUNCNAME} "$*"
	[[ -z "${1}" ]] && die "${FUNCNAME} takes at least one argument"

	local path path_arr=("$@")
	# subshell this to prevent IFS bleeding out dependant on bash version.
	# could use local, which *should* work, but that requires a lot of testing.
	path=$(IFS=":"; echo "${path_arr[*]}")
	dodir /etc/sandbox.d
	echo "SANDBOX_PREDICT=\"${path}\"" > "${ED}/etc/sandbox.d/20${VMHANDLE}" \
		|| die "Failed to write sandbox control file"
}
