# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-devel/autoconf/autoconf-2.63-r1.ebuild,v 1.2 2009/07/27 04:18:45 vapier Exp $

EAPI="2"

inherit eutils rpm lts6-rpm

DESCRIPTION="Used to create autoconfiguration files"
HOMEPAGE="http://www.gnu.org/software/autoconf/autoconf.html"

SRPM="autoconf-2.63-5.1.el6.src.rpm"
SRC_URI="mirror://lts62/vendor/${SRPM}"
RESTRICT="mirror"

LICENSE="GPL-2"
SLOT="2.5"
KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ia64 ~m68k ~mips ~ppc ~ppc64 ~s390 ~sh ~sparc ~sparc-fbsd ~x86 ~x86-fbsd"
IUSE="emacs"

DEPEND=">=sys-apps/texinfo-4.3
	>=sys-devel/m4-1.4.6
	dev-lang/perl"
RDEPEND="${DEPEND}
	>=sys-devel/autoconf-wrapper-6"
PDEPEND="emacs? ( app-emacs/autoconf-mode )"

src_unpack() {
	# Explicit support for lzma archives required.
	rpm_unpack "${SRPM}" || die "rpm_unpack failed!"

	unpack "./${P}.tar.lzma" || die
}

src_prepare() {
	SRPM_PATCHLIST="# Fix for #556223
			Patch0:     autoconf-erlang_fix.diff"
	lts6_srpm_epatch || die

	epatch "${FILESDIR}"/${P}-sh.patch #264303
}

src_configure() {
	# Disable Emacs in the build system since it is in a separate package.
	export EMACS=no
	econf --program-suffix="-${PV}" || die
	# econf updates config.{sub,guess} which forces the manpages
	# to be regenerated which we dont want to do #146621
	touch man/*.1
}

src_compile() {
	# From configure output:
	# Parallel builds via `make -jN' do not work.
	emake -j1 || die
}

src_install() {
	emake DESTDIR="${D}" install || die
	dodoc AUTHORS BUGS NEWS README TODO THANKS \
		ChangeLog ChangeLog.0 ChangeLog.1 ChangeLog.2
}
