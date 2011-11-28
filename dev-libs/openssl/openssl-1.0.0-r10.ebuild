# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-libs/openssl/openssl-1.0.0e.ebuild,v 1.8 2011/10/01 07:28:54 pva Exp $

EAPI="3"

inherit eutils flag-o-matic toolchain-funcs rpm lts6-rpm

REV="1.7"
DESCRIPTION="full-strength general purpose cryptography library (including SSL v2/v3 and TLS v1)"
HOMEPAGE="http://www.openssl.org/"

SRPM="openssl-1.0.0-10.el6_1.5.src.rpm"
SRC_URI="mirror://lts6/vendor/${SRPM}"
RESTRICT="mirror"

LICENSE="openssl"
SLOT="0"
KEYWORDS="alpha amd64 arm hppa ia64 m68k ~mips ppc ppc64 s390 sh sparc x86 ~sparc-fbsd ~x86-fbsd"
IUSE="bindist gmp kerberos rfc3779 sse2 test zlib"

RDEPEND="gmp? ( dev-libs/gmp )
	zlib? ( sys-libs/zlib )
	kerberos? ( app-crypt/mit-krb5 )"
DEPEND="${RDEPEND}
	sys-apps/diffutils
	>=dev-lang/perl-5
	test? ( sys-devel/bc )"
PDEPEND="app-misc/ca-certificates"

# Omiting upstream openssl-1.0.0-beta3-soversion.patch since the
# Gentoo ebuild set's it's own so version.
# Omitting openssl-0.9.8a-no-rpath.patch since the Gentoo patch
# openssl-1.0.0a-ldflags.patch sets that line otherwise.
SRPM_PATCHLIST="Patch0: openssl-1.0.0-beta4-redhat.patch
Patch1: openssl-1.0.0-beta3-defaults.patch
Patch4: openssl-1.0.0-beta5-enginesdir.patch
Patch6: openssl-0.9.8b-test-use-localhost.patch
Patch23: openssl-1.0.0-beta4-default-paths.patch
Patch24: openssl-0.9.8j-bad-mime.patch
Patch25: openssl-1.0.0a-manfix.patch
Patch32: openssl-0.9.8g-ia64.patch
Patch33: openssl-1.0.0-beta4-ca-dir.patch
Patch34: openssl-0.9.6-x509.patch
Patch35: openssl-0.9.8j-version-add-engines.patch
Patch38: openssl-1.0.0-beta5-cipher-change.patch
Patch39: openssl-1.0.0-beta5-ipv6-apps.patch
Patch40: openssl-1.0.0-fips.patch
Patch41: openssl-1.0.0-beta3-fipscheck.patch
Patch43: openssl-1.0.0-beta3-fipsmode.patch
Patch44: openssl-1.0.0-beta3-fipsrng.patch
Patch45: openssl-0.9.8j-env-nozlib.patch
Patch47: openssl-1.0.0-beta5-readme-warning.patch
Patch49: openssl-1.0.0-beta4-algo-doc.patch
Patch50: openssl-1.0.0-beta4-dtls1-abi.patch
Patch51: openssl-1.0.0-version.patch
Patch52: openssl-1.0.0-beta4-aesni.patch
Patch53: openssl-1.0.0-name-hash.patch
Patch54: openssl-1.0.0c-speed-fips.patch
Patch55: openssl-1.0.0c-apps-ipv6listen.patch
Patch56: openssl-1.0.0c-rsa-x931.patch
Patch57: openssl-1.0.0-fips186-3.patch
Patch58: openssl-1.0.0c-fips-md5-allow.patch
Patch59: openssl-1.0.0c-pkcs12-fips-default.patch
Patch90: openssl-1.0.0-cavs.patch
Patch91: openssl-1.0.0-fips-aesni.patch
Patch60: openssl-1.0.0-dtls1-backports.patch
Patch61: openssl-1.0.0-init-sha256.patch
Patch62: openssl-1.0.0-cve-2010-0742.patch
Patch63: openssl-1.0.0-cve-2010-1633.patch
Patch64: openssl-1.0.0-cve-2010-3864.patch
Patch65: openssl-1.0.0-cve-2010-4180.patch
Patch66: openssl-1.0.0-cve-2011-0014.patch
Patch68: openssl-1.0.0-cve-2011-3207.patch"

pkg_setup() {
	if ! use bindist; then
		ewarn
		ewarn \*\*\*\*\* WARNING!!! \*\*\*\*\*
		ewarn The dev-libs/openssl package is currently suffering
		ewarn build failures when built with '-bindist'.
		ewarn Please use '+bindist' on this package until the
		ewarn issue is resolved.
	fi
}

src_unpack() {
	rpm_src_unpack || die
	cp "${FILESDIR}"/${PN}-c_rehash.sh.${REV} "${WORKDIR}"/c_rehash || die
}

src_prepare() {
	local p q

	set -- ${SRPM_PATCHLIST}
	while [ "$1" ]; do
		listatom=$1
		if [[ "${listatom}" != *"atch"* ]]; then
			die "SRPM_PATCHLIST error $1"
		else
			shift
		fi
		patch=$1
		if [[ ! ${patch} ]]; then
			die "Error parsing patch list!"
		fi
		epatch "${WORKDIR}/${patch}" || die
	shift
	done

	epatch "${FILESDIR}"/${PN}-1.0.0a-ldflags.patch #327421
	epatch "${FILESDIR}"/${PN}-1.0.0d-fbsd-amd64.patch #363089
	epatch "${FILESDIR}"/${PN}-1.0.0d-windres.patch #373743
	epatch_user #332661

	# disable fips in the build
	# make sure the man pages are suffixed #302165
	# don't bother building man pages if they're disabled
	sed -i \
		-e '/DIRS/s: fips : :g' \
		-e '/^MANSUFFIX/s:=.*:=ssl:' \
		-e '/^MAKEDEPPROG/s:=.*:=$(CC):' \
		-e $(has noman FEATURES \
			&& echo '/^install:/s:install_docs::' \
			|| echo '/^MANDIR=/s:=.*:=/usr/share/man:') \
		Makefile{,.org} \
		|| die
	# show the actual commands in the log
	sed -i '/^SET_X/s:=.*:=set -x:' Makefile.shared

	# allow openssl to be cross-compiled
	cp "${FILESDIR}"/gentoo.config-1.0.0 gentoo.config || die "cp cross-compile failed"
	chmod a+rx gentoo.config

	append-flags -fno-strict-aliasing
	append-flags $(test-flags-CC -Wa,--noexecstack)

	sed -i '1s,^:$,#!/usr/bin/perl,' Configure #141906
	./config --test-sanity || die "I AM NOT SANE"
}

src_configure() {
	unset APPS #197996
	unset SCRIPTS #312551

	tc-export CC AR RANLIB RC

	# Clean out patent-or-otherwise-encumbered code
	# Camellia: Royalty Free            http://en.wikipedia.org/wiki/Camellia_(cipher)
	# IDEA:     5,214,703 07/01/2012    http://en.wikipedia.org/wiki/International_Data_Encryption_Algorithm
	# EC:       ????????? ??/??/2015    http://en.wikipedia.org/wiki/Elliptic_Curve_Cryptography
	# MDC2:     Expired                 http://en.wikipedia.org/wiki/MDC-2
	# RC5:      5,724,428 03/03/2015    http://en.wikipedia.org/wiki/RC5

	use_ssl() { use $1 && echo "enable-${2:-$1} ${*:3}" || echo "no-${2:-$1}" ; }
	echoit() { echo "$@" ; "$@" ; }

	local krb5=$(has_version app-crypt/mit-krb5 && echo "MIT" || echo "Heimdal")

	local sslout=$(./gentoo.config)
	einfo "Use configuration ${sslout:-(openssl knows best)}"
	local config="Configure"
	[[ -z ${sslout} ]] && config="config"
	echoit \
	./${config} \
		${sslout} \
		$(use sse2 || echo "no-sse2") \
		enable-camellia \
		$(use_ssl !bindist ec) \
		$(use_ssl !bindist idea) \
		enable-mdc2 \
		$(use_ssl !bindist rc5) \
		enable-tlsext \
		$(use_ssl gmp gmp -lgmp) \
		$(use_ssl kerberos krb5 --with-krb5-flavor=${krb5}) \
		$(use_ssl rfc3779) \
		$(use_ssl zlib) \
		--prefix=/usr \
		--openssldir=/etc/ssl \
		--libdir=$(get_libdir) \
		shared threads \
		|| die "Configure failed"

	# Clean out hardcoded flags that openssl uses
	local CFLAG=$(grep ^CFLAG= Makefile | LC_ALL=C sed \
		-e 's:^CFLAG=::' \
		-e 's:-fomit-frame-pointer ::g' \
		-e 's:-O[0-9] ::g' \
		-e 's:-march=[-a-z0-9]* ::g' \
		-e 's:-mcpu=[-a-z0-9]* ::g' \
		-e 's:-m[a-z0-9]* ::g' \
	)
	sed -i \
		-e "/^CFLAG/s|=.*|=${CFLAG} ${CFLAGS}|" \
		-e "/^SHARED_LDFLAGS=/s|$| ${LDFLAGS}|" \
		Makefile || die
}

src_compile() {
	# depend is needed to use $confopts
	# rehash is needed to prep the certs/ dir
	emake -j1 depend || die "depend failed"
	emake -j1 all rehash || die "make all failed"
}

src_test() {
	emake -j1 test || die "make test failed"
}

src_install() {
	emake -j1 INSTALL_PREFIX="${D}" install || die
	dobin "${WORKDIR}"/c_rehash || die #333117
	dodoc CHANGES* FAQ NEWS README doc/*.txt doc/c-indentation.el
	dohtml -r doc/*
	use rfc3779 && dodoc engines/ccgost/README.gost

	# create the certs directory
	dodir /etc/ssl/certs
	cp -RP certs/* "${D}"/etc/ssl/certs/ || die "failed to install certs"
	rm -r "${D}"/etc/ssl/certs/{demo,expired}

	# Namespace openssl programs to prevent conflicts with other man pages
	cd "${D}"/usr/share/man
	local m d s
	for m in $(find . -type f | xargs grep -L '#include') ; do
		d=${m%/*} ; d=${d#./} ; m=${m##*/}
		[[ ${m} == openssl.1* ]] && continue
		[[ -n $(find -L ${d} -type l) ]] && die "erp, broken links already!"
		mv ${d}/{,ssl-}${m}
		# fix up references to renamed man pages
		sed -i '/^[.]SH "SEE ALSO"/,/^[.]/s:\([^(, ]*(1)\):ssl-\1:g' ${d}/ssl-${m}
		ln -s ssl-${m} ${d}/openssl-${m}
		# locate any symlinks that point to this man page ... we assume
		# that any broken links are due to the above renaming
		for s in $(find -L ${d} -type l) ; do
			s=${s##*/}
			rm -f ${d}/${s}
			ln -s ssl-${m} ${d}/ssl-${s}
			ln -s ssl-${s} ${d}/openssl-${s}
		done
	done
	[[ -n $(find -L ${d} -type l) ]] && die "broken manpage links found :("

	dodir /etc/sandbox.d #254521
	echo 'SANDBOX_PREDICT="/dev/crypto"' > "${D}"/etc/sandbox.d/10openssl

	diropts -m0700
	keepdir /etc/ssl/private
}

pkg_preinst() {
	has_version ${CATEGORY}/${PN}:0.9.8 && return 0
	preserve_old_lib /usr/$(get_libdir)/lib{crypto,ssl}.so.0.9.8
}

pkg_postinst() {
	ebegin "Running 'c_rehash ${ROOT}etc/ssl/certs/' to rebuild hashes #333069"
	c_rehash "${ROOT}etc/ssl/certs" >/dev/null
	eend $?

	has_version ${CATEGORY}/${PN}:0.9.8 && return 0
	preserve_old_lib_notify /usr/$(get_libdir)/lib{crypto,ssl}.so.0.9.8
}
