#!/bin/sh

###
### CONSTANTS
###

app="/app"
appnweb="$app/web"
conf="/config"
e2g_ssl="$conf/ssl"
e2g_servercerts="$e2g_ssl/servercerts"
e2g_gencerts="$e2g_ssl/generatedcerts"
e2g_capubkeycrt="$e2g_servercerts/cacertificate.crt"
e2g_capubkeyder="$e2g_servercerts/my_rootCA.der"
nweb_crt="$appnweb/cacertificate.crt"
nweb_der="$appnweb/my_rootCA.der"


###
### FUNCTIONS
###

file_exists() {
    local f="$1"
    stat $f &>/dev/null
}


###
### MAIN
###

#Set UID and GID of e2guardian account
#-------------------------------------
groupmod -o -g $PGID e2guardian
usermod -o -u $PUID e2guardian

#Verify important files in Docker volumes exist
#----------------------------------------------
if (! file_exists "$conf/*"); then
    echo "INFO: $conf is empty -- extracting $app/config.gz to $conf"
    tar xzf $app/config.gz -C /
fi

#Remove any existing .pid file that could prevent e2guardian from starting
#-------------------------------------------------------------------------
rm -rf $app/pid/e2guardian.pid

#Ensure correct ownership and permissions
#----------------------------------------
chown -R e2guardian:e2guardian /app /config
chmod -R 755 $e2g_servercerts
chmod -R 700 $e2g_servercerts/*.pem $e2g_gencerts

#Prep E2Guardian
#---------------
[[ "$E2G_MITM" = "on" ]] && args="e" || args="d"
e2g-mitm.sh -$args

#Start Filebrowser
#-----------------
if [[ "$FILEBROWSER" = "on" ]]; then
    # For first time running Filebrowser, quickly run it then kill it so that a .db file is created
    if (! file_exists "$FILEBROWSER_DB"); then
        (filebrowser \
            -a $FILEBROWSER_ADDR \
            -p $FILEBROWSER_PORT \
            -r $FILEBROWSER_ROOT \
            -d $FILEBROWSER_DB \
            -l $FILEBROWSER_LOG &) && sleep 1 && pkill filebrowser
    fi
    # Add a 'Command Runner' that restarts the container if /config/_DELETE_ME_TO_RESTART_E2G is
    # deleted via Filebrowser.  This makes it easy for the admin to restart the E2G service
    # without having to issue docker commands.
    if ( ! filebrowser -d $FILEBROWSER_DB cmds ls | grep -q "after_delete(.*pkill entrypoint\.sh" ); then
        filebrowser -d $FILEBROWSER_DB cmds add \
            "after_delete" \
            "sh -c \"[[ \$FILE == '/config/_DELETE_ME_TO_RESTART_E2G' ]] && pkill entrypoint.sh\"";
    fi
    # Now we'll actually run Filebrowser    
    (filebrowser \
        -a $FILEBROWSER_ADDR \
        -p $FILEBROWSER_PORT \
        -r $FILEBROWSER_ROOT \
        -d $FILEBROWSER_DB \
        -l $FILEBROWSER_LOG &) \
	&& touch /config/_DELETE_ME_TO_RESTART_E2G \
    && echo INFO: Filebrowser started and running on port "$FILEBROWSER_PORT". \
	|| echo ERROR: Filebrowser failed to start!
fi

#Start Nweb
#----------
if [[ "$LIGHTTPD" = "on" ]]; then
    if [[ "$E2G_MITM" = "on" ]]; then
        (file_exists $e2g_capubkeycrt) && (! file_exists $nweb_crt) && ln -s $e2g_capubkeycrt $nweb_crt
        (file_exists $e2g_capubkeyder) && (! file_exists $nweb_der) && ln -s $e2g_capubkeyder $nweb_der
	    lighttpd -f /etc/lighttpd/lighttpd.conf \
		&& echo INFO: Nweb started and running on port 82. \
		|| echo ERROR: Nweb failed to start!
    else
        echo "WARNING: Nweb was configured to start even though SSL MITM is disabled.  Leaving Nweb off as it would serve no function."
    fi
fi

#Create proxy.pac
#----------------

if [[ "$PAC" = "on" ]]; then
    echo -e \
        "function FindProxyForURL(url, host) {" \
        "    if (isPlainHostName(host) || isInNet(host, '"'$PAC_NETWORK'"', '"'$PAC_NETMASK'"')) {" \
        "    return "DIRECT";" \
        "    } else {" \
        "    return '"'PROXY $FQDN:8080'"';" \
        "    }" \
        "}" > /app/nweb/proxy.pac
fi

#Start lighttpd
#--------------


#Start e2guardian
#----------------
e2guardian -N -c $conf/e2guardian.conf
