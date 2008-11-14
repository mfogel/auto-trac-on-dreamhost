# AutoTracOnDreamHost: site.sh
# Released under GLPv3. http://www.gnu.org/licenses/gpl-3.0.html
# Copyright 2008 Michael Fogel. http://fogel.ca

source ./configure.inc

# Prompt for project parameters, with defaults
PROJECT=somesvnproject;         getInput "Subversion Project ID"  PROJECT
DOMAIN=trac.somedomain.com;     getInput "Domain for Trac"        DOMAIN
DOMAINDIR=${HOME}/http/$DOMAIN; getInput "Path for domain root"   DOMAINDIR
TRACPATH=/trac;                 getInput "Relative Path for Trac" TRACPATH
MYSQLHOST=mysql.$DOMAIN;        getInput "MySQL hostname"         MYSQLHOST
MYSQLUSER=trac_username;        getInput "MySQL username"         MYSQLUSER 
MYSQLPASSWD=trac_password;      getInput "MySQL password"         MYSQLPASSWD
MYSQLDBNAME=trac_$PROJECT;      getInput "MySQL DB name"          MYSQLDBNAME
TRAC_USER=admin;                getInput "Trac Admin username"    TRAC_USER
TRAC_PASSWORD=password;         getInput "Trac Admin password"    TRAC_PASSWORD

# confirm those values
echo "Please confirm the values you entered:"
echo "PROJECT:${PROJECT}"
echo "DOMAIN:${DOMAIN}"
echo "DOMAINDIR:${DOMAINDIR}"
echo "TRACPATH:${TRACPATH}"
echo "MYSQLHOST:${MYSQLHOST}"
echo "MYSQLUSER:${MYSQLUSER}"
echo "MYSQLPASSWD:${MYSQLPASSWD}"
echo "MYSQLDBNAME:${MYSQLDBNAME}"
echo "TRAC_USER:${TRAC_USER}"
echo "TRAC_PASSWORD:${TRAC_PASSWORD}"
echo "Look good?"
lookingGood=Yes;
getInput "Looking good? 'Yes' to continue, all else to quit." lookingGood
[ "$lookingGood" != "Yes" ] && exit 1;

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
  permission add $TRAC_USER TRAC_ADMIN
fi

echo "Make Trac Web Accessible"
# Make Trac Web Accessible
mkdir -p ${WEBDIR}
chmod 751 ${WEBDIR}

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
TRACPATH_S=`echo ${TRACPATH} | sed -e "s/\/$//" -e "s/\//\\\\\\ \//g" -e "s/ \//\//g"`
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

#Create .htpasswd file for trac admin with password
htpasswd -bc ${HTPASSWD} $TRAC_USER "$TRAC_PASSWORD"

# Note: on DreamHost you avoid a world-readable htpasswd file by
# setting one up via panel.dreamhost.com->Goodies->Htaccess/WebDAV.
# This will make htpasswd and htaccess files (overwriting anything
# that's there) that has group dhapache, is group readable, and
# the apache user is in the dhapache group.  Baring this, you need
# to make your htpasswd file word-readable (or email support for
# some chgrp action as root)
chmod 644 ${HTPASSWD}

echo ---------- SITE INSTALL COMPLETE! ----------
