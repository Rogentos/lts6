# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-libs/libXvMC/libXvMC-1.0.7.ebuild,v 1.9 2012/08/26 18:48:49 armin76 Exp $

EAPI=4
inherit xorg-2 rpm lts6-rpm

DESCRIPTION="X.Org XvMC library"

KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ia64 ~mips ~ppc ~ppc64 ~s390 ~sh ~sparc ~x86 ~amd64-fbsd ~x86-fbsd ~x86-freebsd ~amd64-linux ~ia64-linux ~x86-linux ~ppc-macos ~x86-solaris"
IUSE=""

SRPM="${PN}-${PV}-8.1.el6.src.rpm"
SRC_URI="mirror://lts63/vendor/${SRPM}"
RESTRICT="mirror"

RDEPEND="x11-libs/libX11
	x11-libs/libXext
	x11-libs/libXv
	x11-proto/videoproto
	x11-proto/xproto"
DEPEND="${RDEPEND}"
PDEPEND="app-admin/eselect-xvmc"

PATCHES=(
	"${FILESDIR}/${PN}-1.0.4-include.patch"
)
