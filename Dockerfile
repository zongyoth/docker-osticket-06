FROM php:7.3-fpm-alpine
MAINTAINER Martin Campbell <martin@campbellsoftware.co.uk>
# environment for osticket
ENV OSTICKET_VERSION=1.16.3
ENV HOME=/data
ENV LD_PRELOAD /usr/lib/preloadable_libiconv.so
WORKDIR /data
RUN set -x && \
    # Fix iconv bug (empty body when mail encoded in quoted-printable)
    apk add gnu-libiconv --update-cache --repository http://dl-cdn.alpinelinux.org/alpine/edge/community/ --allow-untrusted && \
    # requirements and PHP extensions
    apk add --no-cache --update \
        wget \
        msmtp \
        ca-certificates \
        supervisor \
        nginx \
        libpng \
        c-client \
        openldap \
        libintl \
        libxml2 \
        libzip \
        icu \
        openssl && \
    apk add --no-cache --virtual .build-deps \
        imap-dev \
        libpng-dev \
        curl-dev \
        openldap-dev \
        gettext-dev \
        libxml2-dev \
        libzip-dev \
        icu-dev \
        autoconf \
        g++ \
        make \
        pcre-dev \
        git && \
    docker-php-ext-install gd curl ldap mysqli sockets gettext mbstring xml intl opcache zip && \
    docker-php-ext-configure imap --with-imap-ssl && \
    docker-php-ext-install imap && \
    pecl install apcu && docker-php-ext-enable apcu && \
    git clone -b v${OSTICKET_VERSION} --depth 1 https://github.com/osTicket/osTicket.git && \
    ls -hal && \
    cd osTicket && \
    php manage.php deploy --setup --git /data/upload && \
    ls -hal /data/upload/ && \
    cd .. && \
    chown -R www-data:www-data /data/upload && \
    # Hide setup
    mv /data/upload/setup /data/upload/setup_hidden && \
    chown -R root:root /data/upload/setup_hidden && \
    chmod -R go= /data/upload/setup_hidden && \
    # Download languages packs
    wget -nv -O upload/include/i18n/fr.phar https://s3.amazonaws.com/downloads.osticket.com/lang/1.14.x/fr.phar && \
    wget -nv -O upload/include/i18n/ar.phar https://s3.amazonaws.com/downloads.osticket.com/lang/1.14.x/ar.phar && \
    wget -nv -O upload/include/i18n/pt_BR.phar https://s3.amazonaws.com/downloads.osticket.com/lang/1.14.x/pt_BR.phar && \
    wget -nv -O upload/include/i18n/it.phar https://s3.amazonaws.com/downloads.osticket.com/lang/1.14.x/it.phar && \
    wget -nv -O upload/include/i18n/es_ES.phar https://s3.amazonaws.com/downloads.osticket.com/lang/1.14.x/es_ES.phar && \
    wget -nv -O upload/include/i18n/de.phar https://s3.amazonaws.com/downloads.osticket.com/lang/1.14.x/de.phar && \
    wget -nv -O upload/include/i18n/sq.phar https://s3.amazonaws.com/downloads.osticket.com/lang/1.14.x/sq.phar && \
    wget -nv -O upload/include/i18n/ar_EG.phar https://s3.amazonaws.com/downloads.osticket.com/lang/1.14.x/ar_EG.phar && \
    wget -nv -O upload/include/i18n/az.phar https://s3.amazonaws.com/downloads.osticket.com/lang/1.14.x/az.phar && \
    wget -nv -O upload/include/i18n/eu.phar https://s3.amazonaws.com/downloads.osticket.com/lang/1.14.x/eu.phar && \
    wget -nv -O upload/include/i18n/en_GB.phar https://s3.amazonaws.com/downloads.osticket.com/lang/1.14.x/en_GB.phar && \
    wget -nv -O upload/include/i18n/et.phar https://s3.amazonaws.com/downloads.osticket.com/lang/1.14.x/et.phar && \
    wget -nv -O upload/include/i18n/fi.phar https://s3.amazonaws.com/downloads.osticket.com/lang/1.14.x/fi.phar && \
    wget -nv -O upload/include/i18n/gl.phar https://s3.amazonaws.com/downloads.osticket.com/lang/1.14.x/gl.phar && \
    wget -nv -O upload/include/i18n/ka.phar https://s3.amazonaws.com/downloads.osticket.com/lang/1.14.x/ka.phar && \
    wget -nv -O upload/include/i18n/el.phar https://s3.amazonaws.com/downloads.osticket.com/lang/1.14.x/el.phar && \
    wget -nv -O upload/include/i18n/he.phar https://s3.amazonaws.com/downloads.osticket.com/lang/1.14.x/he.phar && \
    wget -nv -O upload/include/i18n/th.phar https://s3.amazonaws.com/downloads.osticket.com/lang/1.14.x/th.phar && \
    wget -nv -O upload/include/i18n/tr.phar https://s3.amazonaws.com/downloads.osticket.com/lang/1.14.x/tr.phar && \
    wget -nv -O upload/include/i18n/uk.phar https://s3.amazonaws.com/downloads.osticket.com/lang/1.14.x/uk.phar && \
    wget -nv -O upload/include/i18n/vi.phar https://s3.amazonaws.com/downloads.osticket.com/lang/1.14.x/vi.phar && \
    mv upload/include/i18n upload/include/i18n.dist && \
    # Download official plugins
    wget -nv -O upload/include/plugins/auth-ldap.phar https://s3.amazonaws.com/downloads.osticket.com/plugin/auth-ldap.phar && \
    wget -nv -O upload/include/plugins/auth-passthru.phar https://s3.amazonaws.com/downloads.osticket.com/plugin/auth-passthru.phar && \
    wget -nv -O upload/include/plugins/storage-fs.phar https://s3.amazonaws.com/downloads.osticket.com/plugin/storage-fs.phar && \
    wget -nv -O upload/include/plugins/storage-s3.phar https://s3.amazonaws.com/downloads.osticket.com/plugin/storage-s3.phar && \
    wget -nv -O upload/include/plugins/audit.phar https://s3.amazonaws.com/downloads.osticket.com/plugin/audit.phar && \
    # Download community plugins (https://forum.osticket.com/d/92286-resources-for-osticket)
    ## Archiver
    git clone https://github.com/clonemeagain/osticket-plugin-archiver upload/include/plugins/archiver && \
    ## Attachment Preview
    git clone https://github.com/clonemeagain/attachment_preview upload/include/plugins/attachment-preview && \
    ## Auto Closer
    git clone https://github.com/clonemeagain/plugin-autocloser upload/include/plugins/auto-closer && \
    ## Fetch Note
    git clone https://github.com/bkonetzny/osticket-fetch-note upload/include/plugins/fetch-note && \
    ## Field Radio Buttons
    git clone https://github.com/Micke1101/OSTicket-plugin-field-radiobuttons upload/include/plugins/field-radiobuttons && \
    ## Mentioner
    git clone https://github.com/clonemeagain/osticket-plugin-mentioner upload/include/plugins/mentioner && \
    ## Multi LDAP Auth
    git clone https://github.com/philbertphotos/osticket-multildap-auth upload/include/plugins/multi-ldap && \
    mv upload/include/plugins/multi-ldap/multi-ldap/* upload/include/plugins/multi-ldap/ && \
    rm -rf upload/include/plugins/multi-ldap/multi-ldap && \
    ## Prevent Autoscroll
    git clone https://github.com/clonemeagain/osticket-plugin-preventautoscroll upload/include/plugins/prevent-autoscroll && \
    ## Rewriter
    git clone https://github.com/clonemeagain/plugin-fwd-rewriter upload/include/plugins/rewriter && \
    ## Slack
    git clone https://github.com/clonemeagain/osticket-slack upload/include/plugins/slack && \
    ## Teams (Microsoft)
    git clone https://github.com/ipavlovi/osTicket-Microsoft-Teams-plugin upload/include/plugins/teams && \
    # Create msmtp log
    touch /var/log/msmtp.log && \
    chown www-data:www-data /var/log/msmtp.log && \
    # File upload permissions
    mkdir -p /var/tmp/nginx && \
    chown nginx:www-data /var/tmp/nginx && chmod g+rx /var/tmp/nginx && \
    # Cleanup
    rm -rf /data/osTicket && \
    find . \( -name ".git" -o -name ".gitignore" -o -name ".gitmodules" -o -name ".gitattributes" \) -exec rm -rf -- {} + && \
    rm -rf /var/cache/apk/* && \
    apk del .build-deps
COPY files/ /
VOLUME ["/data/upload/include/plugins","/data/upload/include/i18n","/var/log/nginx"]
EXPOSE 80
CMD ["/data/bin/start.sh"]