# AutoTracOnDreamHost: configure.inc
# Released under GLPv3. http://www.gnu.org/licenses/gpl-3.0.html
# Copyright 2008 Michael Fogel. http://fogel.ca

# Abort on any errors
set -e

PYTHON_VERS=2.4
TRAC_VERS=0.11.7
GENSHI_VERS=0.6
MYSQLDB_VERS=1.2.3
PYGMENTS_VERS=1.3.1

# trac dir structure
TRAC_ROOT="${HOME}/trac"
PKG=${TRAC_ROOT}/packages
EGG=${TRAC_ROOT}/egg_cache
INSTALL=${TRAC_ROOT}/install
SITES=${TRAC_ROOT}/sites
SVN=${HOME}/svn
TRAC_SITE_PACKAGES=${PKG}/lib/python${PYTHON_VERS}/site-packages
TRAC_HTDOCS=${TRAC_SITE_PACKAGES}/Trac-${TRAC_VERS}-py${PYTHON_VERS}.egg/trac/htdocs

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

TRAC=http://ftp.edgewall.com/pub/trac/Trac-${TRAC_VERS}.tar.gz
GENSHI=http://ftp.edgewall.com/pub/genshi/Genshi-${GENSHI_VERS}.tar.gz
SETUPTOOLS=http://peak.telecommunity.com/dist/ez_setup.py
MYSQLDB=http://switch.dl.sourceforge.net/sourceforge/mysql-python/MySQL-python-${MYSQLDB_VERS}.tar.gz
PYGMENTS=http://pypi.python.org/packages/source/P/Pygments/Pygments-${PYGMENTS_VERS}.tar.gz

TRACDIR=Trac-${TRAC_VERS}
GENSHIDIR=Genshi-${GENSHI_VERS}
MYSQLDBDIR=MySQL-python-${MYSQLDB_VERS}
PYGMENTSDIR=Pygments-${PYGMENTS_VERS}

#### function getInupt - used primarily in site.sh #####
# arg 1: message
# arg 2: initial value
function getInput {
  MES="$1"
  eval "VAL=\$$2"
  echo ""
  echo "Press enter to accept the current value, or input a new value."
  TMP="$VAL"
  while [[ -n "$TMP" ]]; do
    VAL="$TMP"
    echo "$MES: $VAL"
    read TMP
  done
  echo "Using $MES: $VAL"
  eval "$2=\"$VAL\""
}

