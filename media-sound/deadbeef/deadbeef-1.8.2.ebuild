# Copyright 2016-2019 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2

EAPI="7"
inherit rindeal

## github.eclass:
GITHUB_NS="Alexey-Yakovenko"

## functions: dsf:eval
inherit dsf-utils

## functions: rindeal:prefix_flags
inherit rindeal-utils

##
inherit github

## EXPORT_FUNCTIONS: src_prepare, pkg_preinst, pkg_postinst, pkg_postrm
inherit xdg

## functions: eautoreconf
inherit autotools

## functions: apppend-cflags
inherit flag-o-matic

## functions: prune_libtool_files
inherit ltprune

DESCRIPTION="Music player for *nix-like systems"
HOMEPAGE_A=(
	"http://deadbeef.sf.net/"
	"${GITHUB_HOMEPAGE}"
)
LICENSE_A=(
	"Zlib"

	"public-domain"  # utf8.c, utf8.h
	"BSD-3-Clause"  # fastftoi.h based on libvorbis/vorbis/lib/os.h
	"BSD-2-Clause"  # fft.c, fft.h
	"BSD-3-Clause"  #  md5/md5.c, md5/md5.h
	# ???  # ConvertUTF/ConvertUTF.c, ConvertUTF/ConvertUTF.h
)

SLOT="0"

SRC_URI_A=(
	"${GITHUB_SRC_URI}"

# 	"https://androidhost.org/d/62mdacS -> gettext.patch"
)

KEYWORDS="~amd64 ~arm ~arm64"

IUSE_A=(
	doc
	nls
	static
	rpath

	abstract-socket
	gtk2
	+gtk3

	$(rindeal:prefix_flags  \
		"plugin_decoder_"   \
			aac             \
			adplug          \
			alac            \
			cdda            \
			cdda-paranoia   \
			dca             \
			dumb            \
			ffap            \
			+ffmpeg         \
			flac            \
			gme             \
			mp3             \
			+mp3-libmad     \
			mp3-libmpg123   \
			musepack        \
			opus            \
			psf             \
			sc68            \
			shn             \
			sid             \
			sndfile         \
			tta             \
			vorbis          \
			vtx             \
			wavpack         \
			wildmidi        \
			wma             \
	)
	$(rindeal:prefix_flags  \
		"plugin_output_"    \
			+alsa           \
			nullout         \
			oss             \
			+pulse          \
	)
	$(rindeal:prefix_flags  \
		"plugin_dsp_"       \
			supereq         \
			mono2stereo     \
			src             \
	) # soundtouch
	$(rindeal:prefix_flags  \
		"plugin_misc_"      \
			shellexec       \
			shellexecui     \
			converter       \
			hotkeys         \
			lfm             \
			pltbrowser      \
			notify          \
			artwork         \
			artwork-network \
			artwork-imlib2  \
			oggedit         \
			rgscanner       \
	)
	$(rindeal:prefix_flags  \
		"plugin_vfs_"       \
			zip             \
			curl            \
			mms             \
	)
	$(rindeal:prefix_flags  \
		"plugin_playlist_"  \
			+m3u            \
	)
)

CDEPEND_A=(
	# `AC_CHECK_LIB([intl],`
	"virtual/libintl"

	"gtk3? ("
		# `PKG_CHECK_MODULES(GTK3_DEPS, gtk+-3.0 >= 3.0 gthread-2.0 glib-2.0`
		"x11-libs/gtk+:3"
		"dev-libs/glib:2"
	")"
	# `PKG_CHECK_MODULES(JANSSON, jansson)`
	"$(dsf:eval 'gtk2|gtk3|plugin_misc_shellexec' "dev-libs/jansson")"
	"gtk2? ("
		# `PKG_CHECK_MODULES(GTK2_DEPS, gtk+-2.0 >= 2.12 gthread-2.0 glib-2.0`
		"x11-libs/gtk+:2"
		"dev-libs/glib:2"
	")"
	# `PKG_CHECK_MODULES(ALSA_DEPS, alsa`
	# `AS_IF([test "${enable_alsa}" != "no" -a "${HAVE_ALSA}" = "yes"]`
	"plugin_output_alsa? ( media-libs/alsa-lib )"
	# `PKG_CHECK_MODULES(FFMPEG_DEPS, libavcodec >= 51.0.0 libavutil libavformat >= 52.0.0`
	# `AC_CHECK_HEADER([ffmpeg/avformat.h]`
	"plugin_decoder_ffmpeg? ( media-video/ffmpeg )"
	# `PKG_CHECK_MODULES(PULSE_DEPS, libpulse-simple`
	"plugin_output_pulse? ( media-sound/pulseaudio )"
	# `AC_CHECK_LIB([iconv]`
	"virtual/libiconv"
	"plugin_decoder_mp3? ("
		# `AC_CHECK_LIB([mad]`
		"plugin_decoder_mp3-libmad? ( media-libs/libmad )"
		# `AC_CHECK_LIB([mpg123]`
		"plugin_decoder_mp3-libmpg123? ( media-sound/mpg123 )"
	")"
	"plugin_decoder_vorbis? ("
		# `AC_CHECK_LIB([vorbis]`
		# `AC_CHECK_LIB([vorbisfile]`
		"media-libs/libvorbis"
	")"
	# `PKG_CHECK_MODULES(OPUS, opusfile, HAVE_OPUS=yes`
	"plugin_decoder_opus? ( media-libs/opus )"
	# `AC_CHECK_LIB([ogg]`
	"plugin_misc_oggedit? ( media-libs/libogg )"
	# `AC_CHECK_LIB([FLAC]`
	"plugin_decoder_flac? ( media-libs/flac )"
	# `AC_CHECK_LIB([wavpack]`
	"plugin_decoder_wavpack? ( media-sound/wavpack )"
	# `AC_CHECK_LIB([sndfile]`
	"plugin_decoder_sndfile? ( media-libs/libsndfile )"
	# `AS_IF([test "${HAVE_CURL}" = "yes"],`
	"plugin_vfs_curl? ( net-misc/curl )"
	"plugin_decoder_cdda? ("
		# `AC_CHECK_LIB([cdio]`
		"dev-libs/libcdio"
		# `AC_CHECK_LIB([cddb]`
		"media-libs/libcddb"
		"plugin_decoder_cdda-paranoia? ("
			# `AC_CHECK_LIB([cdda_interface]`
			# `AC_CHECK_LIB([cdda_paranoia]`
			"dev-libs/libcdio-paranoia"
		")"
	")"
	# `AC_CHECK_HEADER([X11/Xlib.h]`
	"plugin_misc_hotkeys? ( x11-libs/libX11 )"
	# `AC_CHECK_HEADERS(sys/soundcard.h)`
	"plugin_output_oss? ( virtual/libc )"
	# `AS_IF([test "${HAVE_CURL}" = "yes"`
	"plugin_misc_lfm? ( net-misc/curl )"
	"plugin_misc_artwork? ("
		# `AS_IF([test "${HAVE_JPEG}" = "yes" -o "${HAVE_IMLIB2}" = "yes"]`
		"|| ("
			"virtual/jpeg:0"
			"media-libs/imlib2"
		")"
		# `PKG_CHECK_MODULES(IMLIB2_DEPS, imlib2`
		"plugin_misc_artwork-imlib2? ( media-libs/imlib2 )"
		# `AS_IF([test "${enable_artwork_imlib2}" = "no" -o "${HAVE_IMLIB2}" = "no"], [`
		"!plugin_misc_artwork-imlib2? ("
			# `AC_CHECK_LIB([png]`
			"media-libs/libpng:0"
			# `PNG_DEPS_LIBS="-lpng -lz"`
			"sys-libs/zlib"
			# `AC_CHECK_LIB([jpeg]`
			"virtual/jpeg:0"
		")"
	")"
	# `PKG_CHECK_MODULES(LIBSAMPLERATE_DEPS, samplerate`
	"plugin_dsp_src? ( media-libs/libsamplerate )"
	# `PKG_CHECK_MODULES(DBUS_DEPS, dbus-1`
	# `AS_IF([test "${HAVE_DBUS}" = "yes"`
	"plugin_misc_notify? ( <sys-apps/dbus-2 )"
	# `AC_CHECK_LIB([faad]`
	"plugin_decoder_aac? ( media-libs/faad2 )"
	# `plugins/mms/mmsplug.c`: `#include <libmms/mmsx.h>`
	"plugin_vfs_mms? ( media-libs/libmms )"
	"plugin_vfs_zip? ("
		# `AS_IF([test "${HAVE_ZLIB}" = "yes" -a "${HAVE_ZIP}" = "yes"]`

		# `AC_CHECK_LIB([z]`
		"sys-libs/zlib"
		# `PKG_CHECK_MODULES(ZIP, libzip`
		"dev-libs/libzip"
	")"
)
DEPEND_A=( "${CDEPEND_A[@]}"
	"virtual/pkgconfig"
	# `AS_IF([test "${HAVE_YASM}" = "yes"`
	"plugin_decoder_ffap? ( dev-lang/yasm )"
)
RDEPEND_A=( "${CDEPEND_A[@]}" )

my_filter()
{
	local pattern="${1}" ; shift
	local haystack=( "${@}" )
	local f regex="^(-|\+)*([a-zA-Z0-9_-]*)"
	for f in "${haystack[@]}" ; do
		eval "[[ \"\${f}\" ${pattern} ]] || continue"

		# strip leading signs
		[[ "${f}" =~ ${regex} ]] && echo "${BASH_REMATCH[2]}" || die
	done
}

REQUIRED_USE_A=(
	# doesn't work without a GUI
	"|| ( gtk2 gtk3 )"
	# `AS_IF([test "${enable_shellexecui}" != "no" -a "${enable_shellexec}" != "no"], [`
	# `AS_IF([test "${HAVE_GTK2}" = "yes" -o "${HAVE_GTK3}" = "yes"], [`
	"plugin_misc_shellexecui? ( plugin_misc_shellexec || ( gtk2 gtk3 ) )"
	# at least one of plugin_output_
	"|| ( $(my_filter '== *plugin_output_*' "${IUSE_A[@]}" ) )"
	"plugin_decoder_mp3? ("
		# `echo "MP3 plugin is disabled: can't find either libmad of libmpg123"`
		"|| ("
			"plugin_decoder_mp3-libmpg123"
			"plugin_decoder_mp3-libmad"
		")"
	")"
	"$(dsf:eval \
		"plugin_decoder_mp3-libmpg123|plugin_decoder_mp3-libmad" \
			"plugin_decoder_mp3"
	)"
	"plugin_misc_shellexecui? ("
		# `AS_IF([test "${enable_shellexecui}" != "no" -a "${enable_shellexec}" != "no"]`
		"plugin_misc_shellexec"
		# `AS_IF([test "${HAVE_GTK2}" = "yes" -o "${HAVE_GTK3}" = "yes"]`
		"|| ("
			"gtk2"
			"gtk3"
		")"
	")"
	"plugin_misc_artwork? ("
		# NOTE: this weird logic actually does:
		#     `plugin_misc_artwork-network? ( plugin_vfs_curl )`
		# `AS_IF([test "${HAVE_VFS_CURL}" = "yes" -o "${enable_artwork_network}" = "no" ], [`
		"|| ("
			"plugin_vfs_curl"
			"!plugin_misc_artwork-network"
		")"
	")"
	"plugin_misc_converter? ("
		# `AS_IF([test "${HAVE_GTK2}" = "yes" -o "${HAVE_GTK3}" = "yes"]`
		"|| ("
			"gtk2"
			"gtk3"
		")"
	")"
)
RESTRICT+=""

inherit arrays

src_prepare()
{
	# https://github.com/DeaDBeeF-Player/deadbeef/pull/2238
# 	eapply "${DISTDIR}/gettext.patch"
	eapply "${FILESDIR}/70339732d8530570861d8fe26112b9f203077e91.patch"

	eapply_user

	# clear out `docs_DATA`
	rsed -e '/^EXTRA_DIST/i docs_DATA =' -i -- Makefile.am

	# `groups extending the format should start with "X-"`
	# TODO: remove in next version; fixed in https://github.com/DeaDBeeF-Player/deadbeef/commit/7dc7ef37bcbe4a2d5926d1b0ae9f59f3ee8b56da
	rsed -r -e '\@^\[[^]]* Shortcut Group\]@ s@^\[@[X-@' -i -- "${PN}.desktop.in"

	# automake: `error: required file `./config.rpath' not found`
	touch config.rpath || die

	eautoreconf
}

my_gen_econf_args()
{
	local -n var_out="$1" ; shift
	local type="$1" ; shift
	local cat="${1}" ; shift

	local f
	local list=( $(my_filter "== *${cat}_*" ${IUSE}) )
	for f in "${list[@]}"
	do
		if [[ "${f}" == "${cat}_"* ]]
		then
			local opt="${f##"${cat}_"}"
			var_out["${f}"]="$(use_${type} "${f}" "${opt}")"
		fi
	done
}

src_configure()
{
	# gtk/glib produce lots of these
	append-cflags "-Wno-deprecated-declarations"

	# plugin lists can be generated with
	#     $ ag --files-with-matches DB_PLUGIN_DECODER plugins | grep -Po '(?<=plugins/)[^/]+' | sort
	local -A gen_econf_args=()

	local g groups=(
		# Output plugins (DB_PLUGIN_OUTPUT)
		plugin_output
		# Decoder plugins (DB_PLUGIN_DECODER)
		plugin_decoder
		# Decoder plugins (DB_PLUGIN_MISC)
		plugin_misc

		plugin_dsp
		plugin_playlist
		plugin_vfs
	)
	for g in "${groups[@]}"
	do
		my_gen_econf_args gen_econf_args enable "${g}"
	done

	## here is the place for any modifications of the generated options
	unset gen_econf_args['plugin_misc_oggedit'] # it's an internal plugin
	gen_econf_args['plugin_vfs_curl']="$(use_enable plugin_vfs_curl vfs-curl)"
	gen_econf_args['plugin_vfs_zip']="$(use_enable plugin_vfs_zip vfs-zip)"
	gen_econf_args['plugin_decoder_mp3-libmad']="$(use_enable plugin_decoder_mp3-libmad libmad)"
	gen_econf_args['plugin_decoder_mp3-libmpg123']="$(use_enable plugin_decoder_mp3-libmpg123 libmpg123)"

	local -a my_econf_args=(
		--disable-coreaudio  # MacOS
		--disable-portable

		$(use_enable rpath)
		$(use_enable static staticlink)
		--disable-static # --enable-static does nothing

		$(use_enable nls)
		$(use_enable abstract-socket)	# use abstract UNIX socket for IPC (default: disabled)

		## GUI
		$(use_enable gtk3)		# disable GTK3 version of gtkui plugin (default: enabled)
		$(use_enable gtk2)		# disable GTK2 version of gtkui plugin (default: enabled)
	)
	econf "${gen_econf_args[@]}" "${my_econf_args[@]}"
}

src_install()
{
	default

	prune_libtool_files --modules

	## make items in the `Help` menu available
	local f
	for f in help.txt ChangeLog about.txt translators.txt COPYING.GPLv2 COPYING.LGPLv2.1
	do
		dodoc "${f}"
		# exclude from the compression list
		docompress -x "/usr/share/doc/${PF}/${f}"
	done
}
