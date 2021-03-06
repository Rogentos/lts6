# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-perl/URI/URI-1.600.0.ebuild,v 1.9 2012/08/27 18:39:04 armin76 Exp $

EAPI=4

MODULE_AUTHOR=GAAS
MODULE_VERSION=1.40
inherit perl-module rpm lts6-rpm

DESCRIPTION="A URI Perl Module"

SLOT="0"
KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ia64 ~m68k ~mips ~ppc ~ppc64 ~s390 ~sh ~sparc ~x86 ~ppc-aix ~amd64-fbsd ~x86-fbsd ~ia64-hpux ~x86-interix ~amd64-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris"
IUSE=""

SRPM="perl-URI-1.40-2.el6.src.rpm"
SRC_URI="mirror://lts63/vendor/${SRPM}"
RESTRICT="mirror"

DEPEND="virtual/perl-MIME-Base64"
RDEPEND="${DEPEND}"

SRC_TEST=no # see ChangeLog

mydoc="rfc2396.txt"
