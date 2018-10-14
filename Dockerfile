FROM ubuntu:16.04

MAINTAINER Will Wright <signup@noimagination.com>

# disable interactive functions
ARG DEBIAN_FRONTEND=noninteractive

RUN export LC_ALL=en_US.UTF-8 && export LANG=en_US.UTF-8 && \
    apt-get update && \
    apt-get install -y --allow-unauthenticated software-properties-common ntp build-essential build-essential binutils \
    zlib1g-dev python-pip language-pack-en-base curl wget git acl lzop unzip && \
    add-apt-repository ppa:ondrej/php && \
    apt-get update && \
    apt-get install -y --allow-unauthenticated \
    mysql-client mcrypt expat xsltproc apache2 apache2-utils libapache2-mod-php \
    php7.0 php7.0-mcrypt php7.0-curl php7.0-common php7.0-gd \
    php7.0-dev php7.0-opcache php7.0-json php7.0-mysql php7.0-readline php7.0-xsl php7.0-xmlrpc \
    php7.0-intl php7.0-zip php7.0-soap php7.0-cli php7.0-xml php7.0-mbstring php7.0-bcmath php-redis \
    php7.0-bz2 php7.0-imagick php7.0-xdebug vsftp \
    && apt-get remove -y php7.1-cli php7.1-common php7.1-json php7.1-readline php7.1-opcache libapache2-mod-php7.1 \
    && apt-get remove -y php7.2-cli php7.2-common php7.2-json php7.2-readline php7.2-opcache libapache2-mod-php7.2 \
    && phpenmod mcrypt xsl imagick xdebug \
    && a2enmod headers rewrite ssl expires php7.0 \
    && adduser --ui 501 --ingroup www-data --shell /bin/bash --home /home/builder builder \
#
#   Install Composer
#
    && curl -sSL https://getcomposer.org/composer.phar -o /usr/bin/composer \
    && chmod +x /usr/bin/composer \
#
#   Install n98-magerun
#
    && cd ~ && wget https://files.magerun.net/n98-magerun2.phar && \
    chmod +x ./n98-magerun2.phar && \
    cp ./n98-magerun2.phar /usr/local/bin/

#
#   Install ionCube
#
COPY ioncube /usr/lib/php/20151012
COPY etc/php/7.0/mods-available/ioncube.ini /etc/php/7.0/mods-available/ioncube.ini
RUN phpenmod ioncube

#
#   Delete prepackaged defaults
#
RUN rm -rf /etc/apache2/ports.conf /etc/apache2/sites-enabled/* /var/lib/apt/lists/*

#
#   Inject config files at the end to optimize build cache
#
COPY etc/apache2/sites-available /etc/apache2/sites-available
COPY etc/apache2/ports.conf /etc/apache2/ports.conf

RUN a2ensite site site-ssl && service apache2 restart

RUN chown -R builder:www-data /var/www/html

COPY configs/apache2/php.ini /etc/php/7.0/apache2/php.ini
COPY configs/cli/php.ini /etc/php/7.0/cli/php.ini

COPY provision/magento /usr/local/bin/magento
COPY provision/xmagento /usr/local/bin/xmagento
COPY provision/n98magerun2 /usr/local/bin/n98magerun2
COPY provision/xn98magerun2 /usr/local/bin/xn98magerun2

RUN chmod a+x /usr/local/bin/magento /usr/local/bin/xmagento /usr/local/bin/n98magerun2 /usr/local/bin/xn98magerun2

EXPOSE 80
RUN service apache2 restart
WORKDIR /var/www/html/current