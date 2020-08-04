EAPI=5

DESCRIPTION="Open source system for file encryption on GNU/Linux."
HOMEPAGE="https://www.dyne.org/software/tomb/"
SRC_URI="https://files.dyne.org/tomb/tomb-${PV}.tar.gz"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ia64 ~ppc ~ppc64 ~sparc ~x86 ~x86-fbsd ~x86-freebsd ~x86-interix ~amd64-linux ~x86-linux"
IUSE="+wipe"

RDEPEND="app-admin/sudo
	app-crypt/gnupg
	app-crypt/pinentry
	app-shells/zsh
	sys-fs/cryptsetup
	wipe? ( app-misc/wipe )"

src_install() {
	emake PREFIX="${D}" install
	dodoc ChangeLog.txt README.txt
}
