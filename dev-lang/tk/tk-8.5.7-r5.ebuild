# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-lang/tk/tk-8.5.7-r1.ebuild,v 1.3 2010/06/16 00:10:30 mr_bones_ Exp $

EAPI="3"
inherit autotools eutils multilib toolchain-funcs rpm lts6-rpm

MY_P="${PN}${PV/_beta/b}"
DESCRIPTION="Tk Widget Set"
HOMEPAGE="http://www.tcl.tk/"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ia64 ~mips ~ppc ~ppc64 ~s390 ~sh ~sparc ~x86 ~x86-fbsd"
IUSE="debug threads truetype"

SRPM="tk-8.5.7-5.el6.src.rpm"
SRC_URI="mirror://lts62/vendor/${SRPM}"
RESTRICT="mirror"

RDEPEND="x11-libs/libX11
	~dev-lang/tcl-${PV}"
DEPEND="${RDEPEND}
	truetype? ( x11-libs/libXft )
	x11-libs/libXt
	x11-proto/xproto"

S="${WORKDIR}/${MY_P}"

SRPM_PATCHLIST="
Patch1: tk8.5-make.patch
Patch2: tk8.5-conf.patch
# this patch isn't needed since tk8.6b1
Patch3: tk-seg_input.patch
# this patch is tracked in tk tracker
Patch4: tk-8.5.7-color.patch
# fixes sigsegv if there is no font seen by fontconfig (#606671)
Patch5: tk-8.5.7-nofont-sigsegv.patch
"

pkg_setup() {
	if use threads ; then
		ewarn ""
		ewarn "PLEASE NOTE: You are compiling ${P} with"
		ewarn "threading enabled."
		ewarn "Threading is not supported by all applications"
		ewarn "that compile against tcl. You use threading at"
		ewarn "your own discretion."
		ewarn ""
		epause 5
	fi
}

src_unpack() {
	rpm_src_unpack || die
}

src_prepare() {
	lts6_srpm_epatch || die

	epatch "${FILESDIR}"/${PN}-8.4.11-multilib.patch

	# Bug 125971
	# Note: Patch superceeded by SRPM patch tk-8.5-conf.patch
	# epatch "${FILESDIR}"/${PN}-8.5_alpha6-tclm4-soname.patch

	cd "${S}"/unix
	eautoreconf
}

src_configure() {
	tc-export CC
	cd "${S}"/unix

	local mylibdir=$(get_libdir) ; mylibdir=${mylibdir//\/}

	econf \
		--with-tcl=/usr/${mylibdir} \
		$(use_enable threads) \
		$(use_enable truetype xft) \
		$(use_enable debug symbols) || die
}

src_install() {
	#short version number
	local v1
	v1=${PV%.*}

	cd "${S}"/unix
	S= emake DESTDIR="${D}" install || die

	# normalize $S path, bug #280766 (pkgcore)
	local nS="$(cd "${S}"; pwd)"

	# fix the tkConfig.sh to eliminate refs to the build directory
	local mylibdir=$(get_libdir) ; mylibdir=${mylibdir//\/}
	sed -i \
		-e "s,^\(TK_BUILD_LIB_SPEC='-L\)${nS}/unix,\1/usr/${mylibdir}," \
		-e "s,^\(TK_SRC_DIR='\)${nS}',\1/usr/${mylibdir}/tk${v1}/include'," \
		-e "s,^\(TK_BUILD_STUB_LIB_SPEC='-L\)${nS}/unix,\1/usr/${mylibdir}," \
		-e "s,^\(TK_BUILD_STUB_LIB_PATH='\)${nS}/unix,\1/usr/${mylibdir}," \
		-e "s,^\(TK_CC_SEARCH_FLAGS='.*\)',\1:/usr/${mylibdir}'," \
		-e "s,^\(TK_LD_SEARCH_FLAGS='.*\)',\1:/usr/${mylibdir}'," \
		"${D}"/usr/${mylibdir}/tkConfig.sh || die

	# install private headers
	insinto /usr/${mylibdir}/tk${v1}/include/unix
	doins "${S}"/unix/*.h || die
	insinto /usr/${mylibdir}/tk${v1}/include/generic
	doins "${S}"/generic/*.h || die
	rm -f "${D}"/usr/${mylibdir}/tk${v1}/include/generic/tk.h
	rm -f "${D}"/usr/${mylibdir}/tk${v1}/include/generic/tkDecls.h
	rm -f "${D}"/usr/${mylibdir}/tk${v1}/include/generic/tkPlatDecls.h

	# install symlink for libraries
	#dosym libtk${v1}.a /usr/${mylibdir}/libtk.a
	dosym libtk${v1}.so /usr/${mylibdir}/libtk.so
	dosym libtkstub${v1}.a /usr/${mylibdir}/libtkstub.a

	dosym wish${v1} /usr/bin/wish

	cd "${S}"
	dodoc ChangeLog* README changes
}
