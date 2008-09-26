# trac_install_common.sh
# adapted from script from http://wiki.dreamhost.com/DreamTracInstall
# Michael Fogel, 2008.  http://fogel.ca

# Abort on any errors
set -e

TRAC_VERSION=0.11.1

# trac dir structure
TRAC_ROOT="${HOME}/trac"
PKG=${TRAC_ROOT}/packages
EGG=${TRAC_ROOT}/egg_cache
INSTALL=${TRAC_ROOT}/install
SITES=${TRAC_ROOT}/sites
SVN=${HOME}/svn
TRAC_SITE_PACKAGES=${PKG}/lib/python2.3/site-packages
TRAC_HTDOCS=${TRAC_SITE_PACKAGES}/Trac-${TRAC_VERSION}-py2.3.egg/trac/htdocs

EXP_CMD1="export PYTHONPATH=$TRAC_SITE_PACKAGES"
EXP_CMD2="export PYTHON_EGG_CACHE=$EGG"
EXP_CMD3="export LD_LIBRARY_PATH=$PKG/lib"
EXP_CMD4="export PATH=$PKG/bin:\$PATH"

cat <<OutputDreamTracInstallReminder

==== Put the following in your ~/.bash_profile ====
Where trac/packages=PKG
$EXP_CMD1
$EXP_CMD2
$EXP_CMD3
$EXP_CMD4
===================================================

OutputDreamTracInstallReminder

# modify those env vars for the duration of this script too.
$EXP_CMD1
$EXP_CMD2
$EXP_CMD3
if [[ "$PATH" != *"$PKG/bin"* ]]; then export PATH=$PKG/bin:$PATH; fi

# Update version information here and DIRs below.

TRAC=http://ftp.edgewall.com/pub/trac/Trac-${TRAC_VERSION}.tar.gz
GENSHI=http://ftp.edgewall.com/pub/genshi/Genshi-0.5.tar.gz
SETUPTOOLS=http://peak.telecommunity.com/dist/ez_setup.py
MYSQLDB=http://switch.dl.sourceforge.net/sourceforge/mysql-python/MySQL-python-1.2.2.tar.gz
PYGMENTS=http://pypi.python.org/packages/source/P/Pygments/Pygments-0.9.tar.gz

TRACDIR=Trac-${TRAC_VERSION}
GENSHIDIR=Genshi-0.5
MYSQLDBDIR=MySQL-python-1.2.2
PYGMENTSDIR=Pygments-0.9

#### function getInupt - used primarily in site.sh #####
# arg 1: message
# arg 2: initial value
function getInput {
  MES="$1"
	eval "VAL=\$$2"
	echo ""
	echo "Press enter to accept the current value, or input a new value."
	TMP="$VAL"
	while [[ -n "$TMP" ]];
	do
	  VAL="$TMP"
		echo "$MES: $VAL"
		read TMP
	done
	echo "Using $MES: $VAL"
	eval "$2=\"$VAL\""
}

