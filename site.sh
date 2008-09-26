# trac_install_site.sh
# adapted from script from http://wiki.dreamhost.com/DreamTracInstall
# Michael Fogel, 2008.  http://fogel.ca

source ./common.sh

# Defaults
PROJECT=somesvnproject
DOMAIN=trac.somedomain.com
DOMAINDIR=${HOME}/http/$DOMAIN  # default refreshed after sampling DOMAIN
TRACPATH=/trac
MYSQLHOST=mysql.$DOMAIN         # default refreshed after sampling DOMAIN
MYSQLUSER=trac_username
MYSQLPASSWD=trac_password
MYSQLDBNAME=trac_db

# Prompt on those defaults
getInput "Subversion Project ID"                 PROJECT
getInput "Domain for Trac"                       DOMAIN
DOMAINDIR=${HOME}/http/$DOMAIN
MYSQLHOST=mysql.$DOMAIN
getInput "Path for domain root"                  DOMAINDIR
getInput "Path for Trac relative to domain root" TRACPATH
getInput "MySQL hostname"                        MYSQLHOST
getInput "MySQL username"                        MYSQLUSER 
getInput "MySQL password"                        MYSQLPASSWD
getInput "MySQL DB name"                         MYSQLDBNAME

# using these values
echo "PROJECT:${PROJECT}"
echo "DOMAIN:${DOMAIN}"
echo "DOMAINDIR:${DOMAINDIR}"
echo "TRACPATH:${TRACPATH}"
echo "MYSQLHOST:${MYSQLHOST}"
echo "MYSQLUSER:${MYSQLUSER}"
echo "MYSQLPASSWD:${MYSQLPASSWD}"
echo "MYSQLDBNAME:${MYSQLDBNAME}"

# Vars for this site
WEBDIR=${DOMAINDIR}/${TRACPATH}
INDEX_CGI=${WEBDIR}/index.cgi
TRACINI=${SITES}/${PROJECT}/conf/trac.ini
HTACCESS=${WEBDIR}/.htaccess
HTPASSWD=${WEBDIR}/.htpasswd
NAME="Trac: ${DOMAIN}${TRACPATH}/"

echo "Setup site"
if [ ! -d ${SITES}/${PROJECT} ]; then

    #Setup Trac Environment for MySQL
    ${PKG}/bin/trac-admin ${SITES}/${PROJECT} \
        initenv ${PROJECT} \
        "mysql://${MYSQLUSER}:${MYSQLPASSWD}@${MYSQLHOST}/${MYSQLDBNAME}" \
        svn \
        ${SVN}/${PROJECT};

    # set admin user to premissions
    ${PKG}/bin/trac-admin ${SITES}/${PROJECT} \
    permission add admins TRAC_ADMIN
    ${PKG}/bin/trac-admin ${SITES}/${PROJECT} \
    permission add admin admins
fi

echo "Make Trac Web Accessible"
# Make Trac Web Accessible
mkdir -p ${WEBDIR}
chmod 751 ${WEBDIR}

# Copy the cgi-bin dir
mkdir -p ${PKG}/share/trac
cp -fr ${INSTALL}/${TRACDIR}/cgi-bin ${PKG}/share/trac

if [ -f "${INDEX_CGI}" ]; then
    rm ${INDEX_CGI}
fi
echo "#!/bin/bash" >> ${INDEX_CGI}
echo "export HOME=\"/home/${USER}\"" >> ${INDEX_CGI}
echo "export TRAC_ENV=\"$SITES/${PROJECT}\"" >> ${INDEX_CGI}
echo "$EXP_CMD1" >> ${INDEX_CGI}
echo "$EXP_CMD2" >> ${INDEX_CGI}
echo "$EXP_CMD3" >> ${INDEX_CGI}
echo "$EXP_CMD4" >> ${INDEX_CGI}
echo "exec $PKG/share/trac/cgi-bin/trac.cgi" >> ${INDEX_CGI}
chmod 755 ${INDEX_CGI}

# logo in trac.ini 
sed -i "s/^alt = .*$/alt = trac_banner.png/" ${TRACINI}
# some fancy sed to escape forward slashes... simplier patches are welcome.
TRACPATH_S=`echo ${TRACPATH} | sed -e "s/\//\\\\\\ \//g" -e "s/ \//\//g"`
sed -i "s/^src = .*$/src = ${TRACPATH_S}\/chrome\/common\/trac_banner.png/" ${TRACINI}

#Pretty URLs
mkdir -p ${WEBDIR}/chrome
chmod 751 ${WEBDIR}/chrome
ln -sf ${TRAC_HTDOCS} ${WEBDIR}/chrome/common

# .htaccess fun
if [ -f ${HTACCESS} ]; then
    rm ${HTACCESS}
fi

touch ${HTACCESS}
chmod 644 ${HTACCESS}

echo "AuthType Basic" >> ${HTACCESS}
echo "AuthUserFile ${HTPASSWD}" >> ${HTACCESS}
echo "AuthName '${NAME}'" >> ${HTACCESS}
echo "require valid-user" >> ${HTACCESS}
echo "" >> ${HTACCESS}
echo "DirectoryIndex index.cgi" >> ${HTACCESS}
echo "Options ExecCGI FollowSymLinks" >> ${HTACCESS}
echo "" >> ${HTACCESS}
echo "<IfModule mod_rewrite.c>" >> ${HTACCESS}
echo "RewriteEngine On" >> ${HTACCESS}
echo "RewriteCond %{REQUEST_FILENAME} !-f" >> ${HTACCESS}
echo "RewriteCond %{REQUEST_FILENAME} !-d" >> ${HTACCESS}
echo "RewriteRule ^(.*)\$ ${TRACPATH}/index.cgi/\$1 [L]" >> ${HTACCESS}
echo "</IfModule>" >> ${HTACCESS}

#Create .htpasswd file and add admin with default password 'password'
echo "admin:\$apr1\$2PpwG/..\$09tzwaDfzKx4Yu/od5Alw0" >> ${HTPASSWD}

# Note: on dreamhost you avoid a world-readable htpasswd file by setting
# one up via panel.dreamhost.com->Goodies->Htaccess/WebDAV.  This will
# make htpasswd and htaccess files (overwriting anything that's there)
# that has group dhapache, is group readable, and the apache user is in the
# dhapache group.  Baring this, you need to make your htpasswd file 
# word-readable (or email support for some chgrp action as root)
chmod 644 ${HTPASSWD}

echo ---------- SITE INSTALL COMPLETE! ----------
