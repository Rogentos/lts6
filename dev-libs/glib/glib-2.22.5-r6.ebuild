# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-libs/glib/Attic/glib-2.22.5.ebuild,v 1.9 2011/03/26 18:34:04 eva dead $

EAPI="3"

inherit gnome.org libtool eutils flag-o-matic rpm lts6-rpm

DESCRIPTION="The GLib library of C routines"
HOMEPAGE="http://www.gtk.org/"

SRPM="glib2-2.22.5-6.el6.src.rpm"
SRC_URI="mirror://lts6/vendor/${SRPM}"
RESTRICT="mirror"

LICENSE="LGPL-2"
SLOT="2"
KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ia64 ~m68k ~mips ~ppc ~ppc64 ~s390 ~sh ~sparc ~x86 ~sparc-fbsd ~x86-fbsd"
IUSE="debug doc fam selinux xattr"

RDEPEND="virtual/libiconv
	xattr? ( sys-apps/attr )
	fam? ( virtual/fam )"
DEPEND="${RDEPEND}
	>=dev-util/pkgconfig-0.16
	>=sys-devel/gettext-0.11
	doc? (
		>=dev-libs/libxslt-1.0
		>=dev-util/gtk-doc-1.11
		~app-text/docbook-xml-dtd-4.1.2 )"

src_unpack() {
	rpm_src_unpack || die
}

src_prepare() {
	cd "${S}"
	lts6_rpm_spec_epatch "${WORKDIR}/glib2.spec" || die

	if use ia64 ; then
		# Only apply for < 4.1
		local major=$(gcc-major-version)
		local minor=$(gcc-minor-version)
		if (( major < 4 || ( major == 4 && minor == 0 ) )); then
			epatch "${FILESDIR}/glib-2.10.3-ia64-atomic-ops.patch"
		fi
	fi

	# Don't fail gio tests when ran without userpriv, upstream bug 552912
	# This is only a temporary workaround, remove as soon as possible
	epatch "${FILESDIR}/${PN}-2.18.1-workaround-gio-test-failure-without-userpriv.patch"

	# Fix gmodule issues on fbsd; bug #184301
	epatch "${FILESDIR}"/${PN}-2.12.12-fbsd.patch

	# Do not try to remove files on live filesystem, bug #XXX ?
	sed 's:^\(.*"/desktop-app-info/delete".*\):/*\1*/:' \
		-i "${S}"/gio/tests/desktop-app-info.c || die "sed failed"

	[[ ${CHOST} == *-freebsd* ]] && elibtoolize
}

src_configure() {
	local myconf

	epunt_cxx

	# Building with --disable-debug highly unrecommended.  It will build glib in
	# an unusable form as it disables some commonly used API.  Please do not
	# convert this to the use_enable form, as it results in a broken build.
	# -- compnerd (3/27/06)
	use debug && myconf="--enable-debug"

	# Always build static libs, see #153807
	# Always use internal libpcre, bug #254659
	econf ${myconf}                 \
		  $(use_enable xattr)       \
		  $(use_enable doc man)     \
		  $(use_enable doc gtk-doc) \
		  $(use_enable fam)         \
		  $(use_enable selinux)     \
		  --enable-static           \
		  --enable-regex            \
		  --with-pcre=internal      \
		  --with-threads=posix
}

src_install() {
	emake DESTDIR="${D}" install || die "Installation failed"

	# Do not install charset.alias even if generated, leave it to libiconv
	rm -f "${D}/usr/lib/charset.alias"

	dodoc AUTHORS ChangeLog* NEWS* README || die "dodoc failed"

	insinto /etc/profile.d/
	doins "${WORKDIR}/glib2.sh" || die
	doins "${WORKDIR}/glib2.csh" || die
}

src_test() {
	unset DBUS_SESSION_BUS_ADDRESS
	export XDG_CONFIG_DIRS=/etc/xdg
	export XDG_DATA_DIRS=/usr/local/share:/usr/share
	export XDG_DATA_HOME="${T}"
	emake check || die "tests failed"
}
