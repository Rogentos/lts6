# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-vcs/cvs/cvs-1.11.23.ebuild,v 1.2 2011/02/10 18:09:44 grobian Exp $

EAPI=3

inherit eutils rpm lts6-rpm

DESCRIPTION="Concurrent Versions System - source code revision control tools"
HOMEPAGE="http://www.nongnu.org/cvs/"

LICENSE="GPL-2 LGPL-2"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ia64 ~mips ~ppc ~ppc64 ~s390 ~sh ~sparc ~x86 ~ppc-aix ~hppa-hpux ~ia64-hpux ~x86-interix ~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~m68k-mint ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris"
IUSE="doc emacs"

SRPM="cvs-1.11.23-11.el6_0.1.src.rpm"
SRC_URI="http://ftp.scientificlinux.org/linux/scientific/6.1/SRPMS/vendor/${SRPM}
	doc? ( mirror://gnu/non-gnu/cvs/source/stable/${PV}/cederqvist-${PV}.html.bz2
		mirror://gnu/non-gnu/cvs/source/stable/${PV}/cederqvist-${PV}.pdf
		mirror://gnu/non-gnu/cvs/source/stable/${PV}/cederqvist-${PV}.ps )"

DEPEND=">=sys-libs/zlib-1.1.4"

src_unpack() {
        rpm_src_unpack || die
}

src_prepare() {
	# Both the following patches are included in the 
	# SRPM

	# epatch "${FILESDIR}"/${P}-CVE-2010-3846.patch
	# epatch "${FILESDIR}"/${P}-getline64.patch

	cd "${S}"
	lts6_rpm_spec_epatch "${WORKDIR}/${PN}.spec" || die

	# remove a useless binary
	einfo "Removing a compiled binary"
	find "${S}" -type f -name getdate -exec rm \{\} \;
}

src_configure() {
	[[ ${CHOST} == *-interix* ]] && export ac_cv_header_inttypes_h=no

	econf --with-tmpdir=/tmp --without-gssapi || die
}

src_install() {
	einstall || die

	insinto /etc/xinetd.d
	newins "${FILESDIR}"/cvspserver.xinetd.d cvspserver || die "newins failed"

	dodoc BUGS ChangeLog* DEVEL* FAQ HACKING \
		MINOR* NEWS PROJECTS README* TESTS TODO

	if use emacs; then
		insinto /usr/share/emacs/site-lisp
		doins cvs-format.el || die "doins failed"
	fi

	if use doc; then
		dodoc "${DISTDIR}"/cederqvist-${PV}.pdf
		dodoc "${DISTDIR}"/cederqvist-${PV}.ps
		tar xjf "${DISTDIR}"/cederqvist-${PV}.html.tar.bz2
		dohtml -r cederqvist-${PV}.html/*
		cd "${ED}"/usr/share/doc/${PF}/html/
		ln -s cvs.html index.html
	fi
}

src_test() {
	einfo "FEATURES=\"maketest\" has been disabled for dev-vcs/cvs"
}
