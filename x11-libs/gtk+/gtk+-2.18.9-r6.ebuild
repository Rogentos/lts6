# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-libs/gtk+/Attic/gtk+-2.18.9.ebuild,v 1.10 2010/08/18 21:01:25 maekke Exp $

EAPI="4"

inherit gnome.org flag-o-matic eutils libtool virtualx rpm lts6-rpm

DESCRIPTION="Gimp ToolKit +"
HOMEPAGE="http://www.gtk.org/"

LICENSE="LGPL-2"
SLOT="2"
KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ia64 ~mips ~ppc ~ppc64 ~sh ~sparc ~x86 ~x86-fbsd ~x86-freebsd ~x86-interix ~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris"
IUSE="aqua cups debug doc jpeg jpeg2k tiff test vim-syntax xinerama"

SRPM="gtk2-2.18.9-6.el6.src.rpm"
SRC_URI="mirror://lts62/vendor/${SRPM}"
RESTRICT="mirror"

# NOTE: cairo[svg] dep is due to bug 291283 (not patched to avoid eautoreconf)
RDEPEND="!aqua? (
		x11-libs/libXrender
		x11-libs/libX11
		x11-libs/libXi
		x11-libs/libXt
		x11-libs/libXext
		>=x11-libs/libXrandr-1.2.99
		x11-libs/libXcursor
		x11-libs/libXfixes
		x11-libs/libXcomposite
		x11-libs/libXdamage
		>=x11-libs/cairo-1.6[X,svg]
	)
	aqua? (
		>=x11-libs/cairo-1.6[aqua,svg]
	)
	xinerama? ( x11-libs/libXinerama )
	>=dev-libs/glib-2.21.3
	>=x11-libs/pango-1.20
	>=dev-libs/atk-1.13
	media-libs/fontconfig
	x11-misc/shared-mime-info
	>=media-libs/libpng-1.2.43-r2:0
	cups? ( net-print/cups )
	jpeg? ( || ( virtual/jpeg-lts6 virtual/jpeg ) )
	jpeg2k? ( media-libs/jasper )
	tiff? ( >=media-libs/tiff-3.5.7 )
	!<gnome-base/gail-1000"
DEPEND="${RDEPEND}
	>=dev-util/pkgconfig-0.9
	!aqua? (
		x11-proto/xextproto
		x11-proto/xproto
		x11-proto/inputproto
		x11-proto/damageproto
	)
	x86-interix? (
		sys-libs/itx-bind
	)
	xinerama? ( x11-proto/xineramaproto )
	>=dev-util/gtk-doc-am-1.11
	doc? (
		>=dev-util/gtk-doc-1.11
		~app-text/docbook-xml-dtd-4.1.2 )
	test? (
		media-fonts/font-misc-misc
		media-fonts/font-cursor-misc )"
PDEPEND="vim-syntax? ( app-vim/gtk-syntax )"

SRPM_PATCHLIST="
# Biarch changes
Patch0: gtk-lib64.patch
Patch1: system-python.patch
# https://bugzilla.gnome.org/show_bug.cgi?id=583273
Patch2: icon-padding.patch
# https://bugzilla.gnome.org/show_bug.cgi?id=599617
Patch4: fresh-tooltips.patch
# from upstream
Patch5: allow-set-hint.patch
# https://bugzilla.gnome.org/show_bug.cgi?id=599618
Patch8: tooltip-positioning.patch
# http://bugzilla.redhat.com/show_bug.cgi?id=529364
Patch11: gtk2-remove-connecting-reason.patch
# https://bugzilla.gnome.org/show_bug.cgi?id=592582
Patch12: gtk2-preview.patch
Patch13: gtk2-rotate-layout.patch
Patch14: gtk2-landscape-pdf-print.patch
# https://bugzilla.gnome.org/show_bug.cgi?id=600992
Patch15: filesystemref.patch
# from upstream
Patch16: o-minus.patch
# from upstream
Patch17: strftime-format.patch
# from upstream
Patch18: 0001-Avoid-spurious-notifications-from-GtkEntry.patch
# from upstream
Patch19: 0001-Prevent-the-destruction-of-the-menu-label-on-page-re.patch
# from upstream
Patch20: 0002-Yet-another-fix-for-shape-handling.patch
Patch23: gtk2-ppd-reading.patch
# updated translations
# https://bugzilla.redhat.com/show_bug.cgi?id=589238
Patch24: gtk2-translations.patch

# https://bugzilla.redhat.com/show_bug.cgi?id=636476
Patch25: gtk2-translations-gu.patch
# https://bugzilla.redhat.com/show_bug.cgi?id=625440
Patch26: gtk2-translations-mr-te.patch
# https://bugzilla.redhat.com/show_bug.cgi?id=647922
Patch27: gtk2-filechooser-empty-location.patch
"

set_gtk2_confdir() {
	# An arch specific config directory is used on multilib systems
	has_multilib_profile && GTK2_CONFDIR="/etc/gtk-2.0/${CHOST}"
	GTK2_CONFDIR=${GTK2_CONFDIR:=/etc/gtk-2.0}
}

src_prepare() {
	lts6_srpm_epatch || die

	# use an arch-specific config directory so that 32bit and 64bit versions
	# dont clash on multilib systems
	has_multilib_profile && epatch "${FILESDIR}/${PN}-2.8.0-multilib.patch"

	# Don't break inclusion of gtkclist.h, upstream bug 536767
	epatch "${FILESDIR}/${PN}-2.14.3-limit-gtksignal-includes.patch"

	# add correct framework linking options, for aqua
	epatch "${FILESDIR}/${PN}-2.18.5-macosx-aqua.patch"

	# Fix gtkentry setting its buffer to null on destroy, upstream bug 613241
	#
	# Provided by: 0001-Avoid-spurious-notifications-from-GtkEntry.patch
	# in the SRPM.
	# epatch "${FILESDIR}/${PN}-2.18.9-notifications-gtkentry.patch"

	# -O3 and company cause random crashes in applications. Bug #133469
	replace-flags -O3 -O2
	strip-flags

	use ppc64 && append-flags -mminimal-toc

	# Non-working test in gentoo's env
	sed 's:\(g_test_add_func ("/ui-tests/keys-events.*\):/*\1*/:g' \
		-i gtk/tests/testing.c || die "sed 1 failed"
	sed '\%/recent-manager/add%,/recent_manager_purge/ d' \
		-i gtk/tests/recentmanager.c || die "sed 2 failed"

	if use x86-interix; then
		# activate the itx-bind package...
		append-flags "-I${EPREFIX}/usr/include/bind"
		append-ldflags "-L${EPREFIX}/usr/lib/bind"
	fi

	elibtoolize
}

src_configure() {
	# png always on to display icons (foser)
	local myconf="$(use_enable doc gtk-doc) \
		$(use_with jpeg libjpeg) \
		$(use_with jpeg2k libjasper) \
		$(use_with tiff libtiff) \
		$(use_enable xinerama) \
		$(use_enable cups cups auto) \
		--disable-papi \
		--with-libpng"
	if use aqua; then
		myconf="${myconf} --with-gdktarget=quartz"
	else
		myconf="${myconf} --with-gdktarget=x11 --with-xinput"
	fi

	# Passing --disable-debug is not recommended for production use
	use debug && myconf="${myconf} --enable-debug=yes"

	# need libdir here to avoid a double slash in a path that libtool doesn't
	# grok so well during install (// between $EPREFIX and usr ...)
	econf --libdir="${EPREFIX}/usr/$(get_libdir)" ${myconf}
}

src_test() {
	unset DBUS_SESSION_BUS_ADDRESS
	Xemake check || die "tests failed"
}

src_install() {
	emake DESTDIR="${D}" install || die "Installation failed"

	set_gtk2_confdir
	dodir ${GTK2_CONFDIR}
	keepdir ${GTK2_CONFDIR}

	# see bug #133241
	echo 'gtk-fallback-icon-theme = "gnome"' > "${T}/gtkrc"
	insinto ${GTK2_CONFDIR}
	doins "${T}"/gtkrc

	# Enable xft in environment as suggested by <utx@gentoo.org>
	echo "GDK_USE_XFT=1" > "${T}"/50gtk2
	doenvd "${T}"/50gtk2

	dodoc AUTHORS ChangeLog* HACKING NEWS* README* || die "dodoc failed"

	# This has to be removed, because it's multilib specific; generated in
	# postinst
	rm "${ED%/}/etc/gtk-2.0/gtk.immodules"

	# add -framework Carbon to the .pc files
	use aqua && for i in gtk+-2.0.pc gtk+-quartz-2.0.pc gtk+-unix-print-2.0.pc; do
		sed -i -e "s:Libs\: :Libs\: -framework Carbon :" "${ED%/}"/usr/lib/pkgconfig/$i || die "sed failed"
	done
}

pkg_postinst() {
	set_gtk2_confdir

	if [ -d "${EROOT%/}${GTK2_CONFDIR}" ]; then
		gtk-query-immodules-2.0  > "${EROOT%/}${GTK2_CONFDIR}/gtk.immodules"
		gdk-pixbuf-query-loaders > "${EROOT%/}${GTK2_CONFDIR}/gdk-pixbuf.loaders"
	else
		ewarn "The destination path ${EROOT%/}${GTK2_CONFDIR} doesn't exist;"
		ewarn "to complete the installation of GTK+, please create the"
		ewarn "directory and then manually run:"
		ewarn "  cd ${EROOT%/}${GTK2_CONFDIR}"
		ewarn "  gtk-query-immodules-2.0  > gtk.immodules"
		ewarn "  gdk-pixbuf-query-loaders > gdk-pixbuf.loaders"
	fi

	if [ -e "${EROOT%/}"/usr/lib/gtk-2.0/2.[^1]* ]; then
		elog "You need to rebuild ebuilds that installed into" "${EROOT%/}"/usr/lib/gtk-2.0/2.[^1]*
		elog "to do that you can use qfile from portage-utils:"
		elog "emerge -va1 \$(qfile -qC ${EPREFIX}/usr/lib/gtk-2.0/2.[^1]*)"
	fi

	elog "Please install app-text/evince for print preview functionality."
	elog "Alternatively, check \"gtk-print-preview-command\" documentation and"
	elog "add it to your gtkrc."
}
