# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-libs/libusb/Attic/libusb-1.0.3.ebuild,v 1.1 2009/08/30 23:26:54 robbat2 Exp $

EAPI="4"

inherit rpm lts6-rpm

DESCRIPTION="Userspace access to USB devices"
HOMEPAGE="http://libusb.org/"
SRPM="libusb1-1.0.3-1.el6.src.rpm"
SRC_URI="mirror://lts62/vendor/${SRPM}"
RESTRICT="mirror"

LICENSE="LGPL-2.1"
SLOT="1"
KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ia64 ~m68k ~mips ~ppc ~ppc64 ~s390 ~sh ~sparc ~x86 -x86-fbsd"
IUSE="debug doc static-libs"

DEPEND="doc? ( app-doc/doxygen )"
RDEPEND=""

src_unpack() {
	rpm_src_unpack || die
}

src_prepare() {
	# fix bashism in configure script
	sed -i -e 's/test \(.*\) ==/test \1 =/' configure || die
}

src_configure() {
	econf \
		$(use_enable static-libs static) \
		$(use_enable debug debug-log)
}

src_compile() {
	default

	if use doc ; then
		cd doc
		emake docs || die "making docs failed"
	fi
}

src_install() {
	emake DESTDIR="${D}" install || die "emake install failed"
	dodoc AUTHORS ChangeLog NEWS PORTING README THANKS TODO

	if use doc ; then
		insinto /usr/share/doc/${PF}/examples
		doins examples/*.c

		dohtml doc/html/*
	fi

	rm -f "${D}"/usr/lib*/libusb*.la
}
