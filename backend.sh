# trac_install_backend.sh
# adapted from script from http://wiki.dreamhost.com/DreamTracInstall
# Michael Fogel, 2008.  http://fogel.ca

source ./common.sh

echo -e "\n==== Creating need dir structure ===="
[ ! -d ${PKG} ] && mkdir -p ${PKG}
# the egg_cache dir must be writable by your apache cgi/python user
[ ! -d ${EGG} ] && mkdir -p ${EGG} && chmod 770 ${EGG}
[ ! -d ${INSTALL} ] && mkdir -p ${INSTALL}
[ ! -d ${SITES} ] && mkdir -p ${SITES}


echo -e "\n==== Retrieving installation files ===="
cd ${INSTALL}
[ ! -f ${TRACDIR}.tar.gz ] && wget ${TRAC}
[ ! -f ${GENSHIDIR}.tar.gz ] && wget ${GENSHI}
[ ! -f ${MYSQLDBDIR}.tar.gz ] && wget ${MYSQLDB}
[ ! -f ${PYGMENTSDIR}.tar.gz ] && wget ${PYGMENTS}
[ ! -f ez_setup.py ] && wget ${SETUPTOOLS}

echo -e "\n==== Installing Setup Tools ===="
#Create site-packages directory. Script will fail without it.
mkdir -p ${TRAC_SITE_PACKAGES}
[ -z `which easy_install` ] && cd ${INSTALL} && python ez_setup.py --prefix=${PKG}

echo -e "\n==== Installing Pygments ===="
cd ${INSTALL} && tar xzf ${PYGMENTSDIR}.tar.gz
cd ${PYGMENTSDIR} && python setup.py install --prefix=${PKG}

echo -e "\n==== Installing MYSQLdb ===="
cd ${INSTALL} && tar xzf ${MYSQLDBDIR}.tar.gz
cd ${MYSQLDBDIR} && python setup.py install --prefix=${PKG}

echo -e "\n==== Installing Genshi ===="
cd ${INSTALL} && tar xzf ${GENSHIDIR}.tar.gz
cd ${GENSHIDIR} && python setup.py install --prefix=${PKG}

echo -e "\n==== Installing Trac ===="
cd ${INSTALL} && tar xzf ${TRACDIR}.tar.gz
cd ${TRACDIR} && python setup.py install --prefix=${PKG}
mkdir -p ${PKG}/share/trac
cp -fr ${INSTALL}/${TRACDIR}/cgi-bin ${PKG}/share/trac

echo -e "\n==== Setting permissions for Trac htdocs ===="
DIR=${TRAC_HTDOCS}
while [ "$DIR" != "$HOME" ]; do
	chmod o+x $DIR
	DIR=`dirname $DIR`
done
find ${TRAC_HTDOCS} -type d -exec chmod 751 {} \;
find ${TRAC_HTDOCS} -type f -exec chmod 644 {} \;

echo -e "\n==== Backend install complete ===="
