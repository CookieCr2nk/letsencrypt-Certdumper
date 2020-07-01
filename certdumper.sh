DOMAIN=`example.com`
LATESTPRIVKEY=`exec ls /etc/letsencrypt/archive/$DOMAIN/privkey* | sed 's/\([0-9]\+\).*/\1/g' | sort -n | tail -1`
LATESTCHAIN=`exec ls /etc/letsencrypt/archive/$DOMAIN/chain* | sed 's/\([0-9]\+\).*/\1/g' | sort -n | tail -1`
LATESTCERT=`exec ls /etc/letsencrypt/archive/$DOMAIN/cert* | sed 's/\([0-9]\+\).*/\1/g' | sort -n | tail -1`

grep -v -F -x -f $LATESTPRIVKEY.pem /opt/mailserver/mail-data/ssl/server.key

if [ $? -eq 1 ]; then
    echo OK
else
    echo UPDATE
    cp -R $LATESTPRIVKEY.pem /opt/mailserver/mail-data/ssl/server.key
    chown mail:mail /opt/mailserver/mail-data/ssl/server.key
    chmod 600 /opt/mailserver/mail-data/ssl/server.key
    RESTART=TRUE
fi

grep -v -F -x -f $LATESTCHAIN.pem /opt/mailserver/mail-data/ssl/ca.crt

if [ $? -eq 1 ]; then
    echo OK
else
    echo UPDATE
    cp -R $LATESTCHAIN.pem /opt/mailserver/mail-data/ssl/ca.crt
    chown mail:mail /opt/mailserver/mail-data/ssl/ca.crt
    chmod 600 /opt/mailserver/mail-data/ssl/ca.crt
    RESTART=TRUE
fi

grep -v -F -x -f $LATESTCERT.pem /opt/mailserver/mail-data/ssl/server.crt

if [ $? -eq 1 ]; then
    echo OK
else
    echo UPDATE
    cp -R $LATESTCERT.pem /opt/mailserver/mail-data/ssl/server.crt
    chown mail:mail /opt/mailserver/mail-data/ssl/server.crt
    chmod 600 /opt/mailserver/mail-data/ssl/server.crt
    RESTART=TRUE
fi

if [ "$RESTART" == "TRUE" ]; then
    cd /opt/mailserver && docker-compose down && docker-compose up -d
    echo RESTART
fi


