# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-apps/xmessage/xmessage-1.0.3.ebuild,v 1.12 2012/05/11 03:10:10 aballier Exp $

EAPI=4

inherit xorg-2 rpm lts6-rpm

DESCRIPTION="Display a message or query in a window (X-based /bin/echo)"

KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ia64 ~mips ~ppc ~ppc64 ~s390 ~sh ~sparc ~x86 ~amd64-fbsd ~x86-fbsd ~x86-interix ~amd64-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris"
IUSE=""

SRPM="xorg-x11-apps-7.4-10.el6.src.rpm"
SRC_URI="mirror://lts63/vendor/${SRPM}"
SRPM_SUB_PKG="${PN}-${PV}.tar.bz2"
RESTRICT="mirror"

RDEPEND="x11-libs/libXaw
	x11-libs/libXt"
DEPEND="${RDEPEND}"

XORG_CONFIGURE_OPTIONS=( --disable-xprint )

src_unpack() {
	rpm_unpack "${SRPM}" || die "rpm_unpack failed!"
	unpack "./${SRPM_SUB_PKG}" || die "Subpackage unpack failed!"
}
