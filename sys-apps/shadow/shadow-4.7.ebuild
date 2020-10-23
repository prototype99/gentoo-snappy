# Copyright 1999-2016 Gentoo Foundation
# Copyright 2017-2019 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2

EAPI="7"
inherit rindeal

## github.eclass:
GITHUB_NS="shadow-maint"

##
inherit github

## functions: eautoreconf
inherit autotools

## functions: elibtoolize
inherit libtool

## functions: dopamd, newpamd
inherit pam

DESCRIPTION="Utilities to deal with user accounts"
HOMEPAGE_A=(
	"${GITHUB_HOMEPAGE}"
)
LICENSE_A=(
	"|| ("
		"BSD-3-Clause"
		"GPL-2.0-or-later"
	")"
)

SLOT="0"

SRC_URI_A=(
	"${GITHUB_SRC_URI}"
)

KEYWORDS_A=(
	"~"{amd64,arm,arm64}
)
IUSE_A=(
	nls
	rpath
	+man
	+largefile
	static
	audit
	selinux
	acl
	libcrack
	pam
	skey
	xattr
	account-tools-setuid
	subordinate-ids
	utmpx
	shadowgrp
	+sha-crypt
	+nscd

	# flags resolving collisions with util-linux
	+vipw-vigr
	+newgrp
	+su
	+login
	+nologin
	+chfn-chsh

	btrfs
	sssd
	caps
)

L10N_LOCALES=( bs ca cs da de dz el es eu fi fr gl he hu id it ja kk km ko nb ne nl nn pl pt pt_BR ro ru sk sq sv tl tr uk vi zh_CN zh_TW )
inherit l10n-r1

# TODO: review deps in configure.ac
CDEPEND_A=(
	"acl? ( sys-apps/acl:0= )"
	"audit? ( >=sys-process/audit-2.6:0= )"
	"libcrack? ( >=sys-libs/cracklib-2.7-r3:0= )"
	"pam? ( virtual/pam:0= )"
	"skey? ( sys-auth/skey:0= )"
	"selinux? ("
		">=sys-libs/libselinux-1.28:0="
		"sys-libs/libsemanage:0="
	")"
	"nls? ( virtual/libintl )"
	"xattr? ( sys-apps/attr:0= )"
)
DEPEND_A=( "${CDEPEND_A[@]}"
	"app-arch/xz-utils"
	"nls? ("
		"app-text/gnome-doc-utils" # `xml2po` utility
		"sys-devel/gettext"
	")"
	"man? ("
		"dev-libs/libxslt" # `xsltproc` utility
	")"
)
RDEPEND_A=( "${CDEPEND_A[@]}"
	"pam? ( >=sys-auth/pambase-20150213 )"
)

REQUIRED_USE_A=(
	"account-tools-setuid? ( pam )"
)

inherit arrays

src_unpack()
{
	github:src_unpack
}

src_prepare:locales()
{
	local l locales dir="po" pre="" post=".po"

	l10n_set_LINGUAS
	l10n_find_changes_in_dir "${dir}" "${pre}" "${post}"

	if use nls
	then
		l10n_get_locales locales app off
		for l in ${locales}
		do
			if use man
			then
				# not all langs in `po/` dir are present also in `man/` dir
				rsed -r -e "/^SUBDIRS/ s, ${l}( |$), ," -i -- man/Makefile.am
				local f="man/${dir}/${pre}${l}${post}"
				[[ -e "${f}" ]] && \
					rrm "${f}"
			fi
		done
	fi
}

src_prepare()
{
	eapply "${FILESDIR}"/4.1.3-dots-in-usernames.patch

	eapply_user

	src_prepare:locales

	# move `passwd` from `/usr/bin` to `/bin`
	# NOTE: shadow_cv_passwd_dir is being ignored by Makefiles
	rsed -r \
		-e "/^(ubin_PROGRAMS|suidubins)/ s, passwd( |$), ," \
		-e "/^(bin_PROGRAMS|suidbins)/   s,$, passwd," \
		-i -- src/Makefile.am

	if ! use man
	then
		rsed -r -e '/^SUBDIRS/ s, man( |$), ,' -i -- Makefile.am
	fi

	eautoreconf
	elibtoolize
}

src_configure()
{
	# move passwd to / to help recover broke systems #64441
	export shadow_cv_passwd_dir="/bin"

	local -a my_econf_args=(
		### Optional Features:
		--enable-shared
		$(use_enable static)

		$(use_enable shadowgrp)
		$(use_enable man)
		$(use_enable account-tools-setuid)
		$(use_enable utmpx)
		$(use_enable subordinate-ids)
		$(use_enable nls)
		--disable-rpath

		### Optional Packages:
		$(use_with audit)
		$(use_with pam libpam)
		$(use_with btrfs)
		$(use_with selinux)
		$(use_with acl)
		$(use_with xattr attr)
		$(use_with skey)
		#TCB is  unsupported by upstream and actually by everything
		--without-tcb
		$(use_with libcrack)
		$(use_with sha-crypt)
		$(use_with nscd)
		$(use_with sssd)
		# HP-UX 10 limits to 16 characters, so 64 should be pretty safe, unlimited is too dangerous
		--with-group-name-max-length=64
# 		--with-xml-catalog=CATALOG
		$(use_with caps fcaps)
	)

	econf "${my_econf_args[@]}"
}

## Comment out or assign value to definitions in `${ED}/etc/login.defs` file.
my_set_login_opt()
{
	local -- comment="" opt="$1" val="$2"

	local -r -- def_file="/etc/login.defs"

	# always comment it out first if not already, just in case opt is present multiple times
	rsed -r -e "/^${opt}\b/ s|^|#|" -i -- "${ED}${def_file}"

	if [[ -n "${val}" ]]
	then
		# replace only the first occurence
		rsed -e "0,/^#${opt}\b/ s|^#${opt}\b.*|${opt} ${val}|" -i -- "${ED}${def_file}"
	fi

	## print out result
	local res="$(grep -E -m 1 -e "^#?${opt}\b" -- "${ED}${def_file}" || die)"
	echo "* ${def_file}: ${res:-"Unable to find '${opt}' in ${def_file}"}"
}

src_install:login_defs()
{
	insinto /etc
	insopts -m0644
	newins etc/login.defs login.defs

	my_set_login_opt CREATE_HOME yes
	if use pam
	then
		## comment out login.defs options that pam hates
		local opts=(
			CHFN_AUTH
			CONSOLE
			CRACKLIB_DICTPATH
			ENV_HZ
			ENVIRON_FILE
			FAILLOG_ENAB
			FTMP_FILE
			LASTLOG_ENAB
			MAIL_CHECK_ENAB
			MOTD_FILE
			NOLOGINS_FILE
			OBSCURE_CHECKS_ENAB
			PASS_ALWAYS_WARN
			PASS_CHANGE_TRIES
			PASS_MIN_LEN
			PORTTIME_CHECKS_ENAB
			QUOTAS_ENAB
			SU_WHEEL_ONLY
		)
		local sed_args=() opt
		for opt in "${opts[@]}"
		do
			my_set_login_opt ${opt}
			# mark the option for addition of a note
			sed_args+=( -e "/^#${opt}\>/b pamnote" )
		done
		# add notes
		rsed "${sed_args[@]}" \
			-e 'b exit' \
			-e ': pamnote; i# NOTE: This setting should be configured via /etc/pam.d/ and not in this file.' \
			-e ': exit' \
			-i -- "${ED}"/etc/login.defs
	else
		my_set_login_opt MAIL_CHECK_ENAB no
		my_set_login_opt SU_WHEEL_ONLY yes
		my_set_login_opt CRACKLIB_DICTPATH /usr/$(get_libdir)/cracklib_dict
		my_set_login_opt LOGIN_RETRIES 3
		my_set_login_opt ENCRYPT_METHOD SHA512
		my_set_login_opt CONSOLE
	fi
}

my_find_deleter()
{
	local -- dir="${1}" ; shift
	local -r -a patterns=( "${@}" )

	local -a find=( "find" "${dir}" "-(" )

	for (( i = 0 ; i <= ${#patterns[*]} ; i++ ))
	do
		find+=( "-name" "${patterns[i]}" )

		if (( i != ${#patterns[*]} ))
		then
			find+=( "-o" )
		fi
	done

	find+=( "-)" "-print" "-exec" "rm" "-v" "{}" ";" )

	echo "${find[@]}"
	"${find[@]}" || die
}

src_install()
{
	emake DESTDIR="${D}" suidperms=4711 install

	dodoc ChangeLog NEWS TODO doc/{HOWTO,README*,WISHLIST,*.txt}
	newdoc README README.download

	## needed for 'useradd -D'
	insinto /etc/default
	insopts -m0600
	doins "${FILESDIR}"/default/useradd

	src_install:login_defs

	if use pam
	then
		dopamd "${FILESDIR}"/pam.d-include/shadow

		local x
		for x in ch{,g}passwd newusers
		do
			newpamd "${FILESDIR}"/pam.d-include/passwd ${x}
		done
		for x in ch{age,sh,fn} user{add,del,mod} group{add,del,mod}
		do
			newpamd "${FILESDIR}"/pam.d-include/shadow ${x}
		done

		## resolve file collisions

		if use man
		then
			# remove manpages that pam will install for us
			# and/or don't apply when using pam
			my_find_deleter "${ED}/usr/share/man" "suauth.5" "limits.5"
		fi

		# Remove pam.d files provided by sys-auth/pambase
		rrm "${ED}"/etc/pam.d/{login,passwd,su}
	else #!use pam
		insinto /etc
		insopts -m0600
		doins etc/login.access
		doins etc/limits
	fi

	## Remove manpages that are handled by other packages (sys-apps/coreutils sys-apps/man-pages)
	if use man
	then
		my_find_deleter "${ED}/usr/share/man" "passwd.5" "getspnam.3"
	fi

	## BEGIN: resolve collisions with util-linux
	if ! use vipw-vigr
	then
		my_find_deleter "${ED}" "vipw*" "vigr*"
	fi
	if ! use newgrp
	then
		my_find_deleter "${ED}" "newgrp*" "sg*"
	fi
	if ! use su
	then
		my_find_deleter "${ED}" "su*"
	fi
	if ! use login
	then
		my_find_deleter "${ED}" "login*"
	fi
	if ! use nologin
	then
		my_find_deleter "${ED}" "nologin*"
	fi
	if ! use chfn-chsh
	then
		my_find_deleter "${ED}" "chfn*" "chsh*"
	fi
	## END: resolve collisions with util-linux
}

pkg_preinst()
{
	nonfatal rrm "${EPREFIX}/etc/pam.d/system-auth.new"
	nonfatal rrm "${EPREFIX}/etc/login.defs.new"
}

pkg_postinst()
{
	# Enable shadow groups.
	if [[ ! -f "${EPREFIX}/etc/gshadow" ]]
	then
		if grpck -r -R "${EPREFIX}/" 2>/dev/null
		then
			grpconv -R "${EPREFIX}/"
		else
			ewarn "Running 'grpck' returned errors. Please run it by hand, and then"
			ewarn "run 'grpconv' afterwards!"
		fi
	fi
}
