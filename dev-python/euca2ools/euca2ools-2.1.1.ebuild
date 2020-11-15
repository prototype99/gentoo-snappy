# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=4

PYTHON_DEPEND="2"
SUPPORT_PYTHON_ABIS="1"
RESTRICT_PYTHON_ABIS="3.*"

inherit distutils

DESCRIPTION="Euca2ools are command-line tools for interacting with Web services
		that export a REST/Query-based API compatible with Amazon EC2 and S3
		services.The tools can be used with both Amazon's services and with
		installations of the Eucalyptus open-source cloud-computing
		infrastructure. The tools were inspired by command-line tools
		distributed by Amazon (api-tools and ami-tools) and largely accept the
		same options and environment variables."
HOMEPAGE="http://open.eucalyptus.com"
SRC_URI="https://github.com/eucalyptus/${PN}/tarball/${PV}"

LICENSE=""
SLOT="0"
KEYWORDS="~amd64"
IUSE=""

DEPEND="dev-python/setuptools"
RDEPEND="${DEPEND}"

src_unpack() {
	mv ${DISTDIR}/${A} ${DISTDIR}/${A}.tgz
	unpack ${A}.tgz
	mv eucalyptus-euca2ools-* ${P}
}
