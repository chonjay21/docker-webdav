#!/usr/bin/env bash
set -e

FORCE_REINIT_CONFIG=${FORCE_REINIT_CONFIG:=false}
USE_SSL=${USE_SSL:=true}
URL_PREFIX=${URL_PREFIX:=/}
SERVER_NAME=${SERVER_NAME:=WebDav}
APP_UID=${APP_UID:=33}
APP_GID=${APP_GID:=33}
APP_UMASK=${APP_UMASK:=007}
APP_USER_NAME=${APP_USER_NAME:=admin}
APP_USER_PASSWD=${APP_USER_PASSWD:=admin}
if [ -z "$DIGEST_AUTH_REALM" ]; then
	USE_BASIC_AUTH=true
else
	USE_BASIC_AUTH=false
fi

if [ -z "$(ls -A $WEBDAV_USER_CONFIG_DIR)" ] || [ "$FORCE_REINIT_CONFIG" = true ]; then
	echo "[] Creating initial data ..."	
	chmod 770 $WEBDAV_SOURCE_DIR/eventscripts/*.sh || true
	echo "[] Running on_pre_init.sh ..."
		. $WEBDAV_SOURCE_DIR/eventscripts/on_pre_init.sh || true
	echo "[] Done."
	
	
	echo "[] Changing UID/GID: $APP_UID|$APP_GID ..."
		groupmod -g $APP_GID $APACHE_RUN_USER
		usermod -u $APP_UID $APACHE_RUN_USER
	echo "[] Done."
	
	echo "[] Creating Webdav user: $APP_USER_NAME ..."
		mkdir -p $WEBDAV_USER_CONFIG_DIR/htpasswd
		
		if [ "$USE_BASIC_AUTH" = true ]; then
			echo "[] Use BasicAuth"
			echo "[] 	You can change password in the container shell with this command: htpasswd -bc $WEBDAV_USER_CONFIG_DIR/htpasswd/htpasswd.users $APP_USER_NAME otherpassword"
			htpasswd -bc $WEBDAV_USER_CONFIG_DIR/htpasswd/htpasswd.users $APP_USER_NAME $APP_USER_PASSWD
		else
			echo "[] Use DigestAuth"
			echo "[] 	You can change password in the container shell with this command: htdigest -c $WEBDAV_USER_CONFIG_DIR/htpasswd/htpasswd.users "$DIGEST_AUTH_REALM""
			# create digest from environment variables directly (htdigest can not do this)
			# htdigest -c $WEBDAV_USER_CONFIG_DIR/htpasswd/htpasswd.users "$DIGEST_AUTH_REALM"
			digest="$( printf "%s:%s:%s" "$APP_USER_NAME" "$DIGEST_AUTH_REALM" "$APP_USER_PASSWD" | md5sum | awk '{print $1}' )"
			printf "%s:%s:%s\n" "$APP_USER_NAME" "$DIGEST_AUTH_REALM" "$digest" >> "$WEBDAV_USER_CONFIG_DIR/htpasswd/htpasswd.users"
		fi
	echo "[] Done."
	
	
	echo "[] Coping configs ..."
		mkdir -p $WEBDAV_CONFIG_PATH
		cp $WEBDAV_SOURCE_DIR/webdav.conf $WEBDAV_CONFIG_PATH/
		
		if [ ! "$URL_PREFIX" = / ]; then
			sed -i "s|Alias / /var/webdav/|Alias $URL_PREFIX /var/webdav/|g" $WEBDAV_CONFIG_PATH/webdav.conf
			sed -i "s|<Location />|<Location $URL_PREFIX/>|g" $WEBDAV_CONFIG_PATH/webdav.conf
		fi

		if [ "$USE_BASIC_AUTH" = false ]; then
			sed -i "s|AuthType Basic|AuthType Digest\n\tAuthDigestProvider file|g" $WEBDAV_CONFIG_PATH/webdav.conf
		fi

		mkdir -p $APACHE_CONFIG_PATH
		cp $WEBDAV_SOURCE_DIR/httpd.conf $APACHE_CONFIG_PATH/
		
		echo "" >> $APACHE_CONFIG_PATH/httpd.conf
		echo "ServerName $SERVER_NAME" >> $APACHE_CONFIG_PATH/httpd.conf
		if [ "$USE_SSL" = true ]; then
			echo "" >> $APACHE_CONFIG_PATH/httpd.conf
			echo "Include conf/extra/httpd-ssl.conf" >> $APACHE_CONFIG_PATH/httpd.conf
		fi
	echo "[] Done."
	
	echo "[] Fixing permision ..."
		chown $APACHE_RUN_USER:$APACHE_RUN_USER $APACHE_CONFIG_PATH/httpd.conf
		chmod 660 $APACHE_CONFIG_PATH/httpd.conf
		chown $APACHE_RUN_USER:$APACHE_RUN_USER $WEBDAV_CONFIG_PATH/webdav.conf
		chmod 660 $WEBDAV_CONFIG_PATH/webdav.conf
		chown -R $APACHE_RUN_USER:$APACHE_RUN_USER $WEBDAV_USER_CONFIG_DIR
		chmod -R 770 $WEBDAV_USER_CONFIG_DIR
	echo "[] Done."
	
	
	echo "[] Running on_post_init.sh ..."
		. $WEBDAV_SOURCE_DIR/eventscripts/on_post_init.sh || true
	echo "[] Done."	
	echo "[] Initialize complete."
else
	echo "[] Skip initializing"
fi


echo "[] Running on_run.sh ..."
. $WEBDAV_SOURCE_DIR/eventscripts/on_run.sh || true
echo "[] Done."	
echo "[] Run httpd ..."
(umask $APP_UMASK && httpd-foreground "$@")
echo "[] Done."
