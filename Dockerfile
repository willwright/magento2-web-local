FROM ubuntu:16.04

MAINTAINER Will Wright <signup@noimagination.com>

# disable interactive functions
ARG DEBIAN_FRONTEND=noninteractive

RUN export LC_ALL=en_US.UTF-8 && export LANG=en_US.UTF-8 && \
    apt-get update && \
    apt-get install -y --allow-unauthenticated software-properties-common ntp build-essential build-essential binutils \
    zlib1g-dev python-pip language-pack-en-base curl wget git acl lzop unzip nano && \
    add-apt-repository ppa:ondrej/php && \
    apt-get update && \
    apt-get install -y --allow-unauthenticated \
    openssh-server mysql-client mcrypt expat xsltproc apache2 apache2-utils libapache2-mod-php \
    php7.2 php7.2-curl php7.2-common php7.2-gd \
    php7.2-dev php7.2-opcache php7.2-json php7.2-mysql php7.2-readline php7.2-xsl php7.2-xmlrpc \
    php7.2-intl php7.2-zip php7.2-soap php7.2-cli php7.2-xml php7.2-mbstring php7.2-bcmath php-redis \
    php7.2-bz2 php7.2-imagick php7.2-xdebug vsftpd telnet \
    && phpenmod mcrypt xsl imagick \
    && a2enmod headers rewrite ssl expires php7.2 \
    && adduser --ui 501 --ingroup www-data --shell /bin/bash --home /home/builder builder \
    && update-alternatives --set php /usr/bin/php7.2 \
    && update-alternatives --set phar /usr/bin/phar7.2 \
    && update-alternatives --set phar.phar /usr/bin/phar.phar7.2 \
    && update-alternatives --set phpize /usr/bin/phpize7.2 \
    && update-alternatives --set php-config /usr/bin/php-config7.2 \

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

RUN echo "root:password123" | chpasswd

#
#   Configure SSH
#
#COPY configs/sshd_config /etc/ssh/sshd_config
#RUN service ssh restart

#
#   Install ionCube
#
#COPY ioncube /usr/lib/php/20151012
#COPY etc/php/7.2/mods-available/ioncube.ini /etc/php/7.2/mods-available/ioncube.ini
#RUN phpenmod ioncube

#
#   Delete prepackaged defaults
#
RUN rm -rf /etc/apache2/ports.conf /etc/apache2/sites-enabled/* /var/lib/apt/lists/*

#
#   Run apache in foreground
#
COPY files/apache2-foreground /usr/local/bin/
RUN chmod +x /usr/local/bin/apache2-foreground

#
#   Inject config files at the end to optimize build cache
#
COPY etc/apache2/sites-available /etc/apache2/sites-available
COPY etc/apache2/ports.conf /etc/apache2/ports.conf

#
#   Xdebug setup
#
COPY etc/php/7.2/mods-available/xdebug.ini etc/php/7.2/mods-available/xdebug.ini
RUN touch /var/log/xdebug.log && chmod a+rwx /var/log/xdebug.log
RUN phpenmod xdebug


RUN a2ensite site site-ssl && service apache2 restart

RUN chown -R builder:www-data /var/www/html

COPY configs/apache2/php.ini /etc/php/7.2/apache2/php.ini
COPY configs/cli/php.ini /etc/php/7.2/cli/php.ini

#
#   VSFTPD configs
#
COPY configs/ftpusers /etc/ftpusers
COPY configs/vsftpd.conf /etc/vsftpd.conf
RUN service vsftpd restart || true

COPY provision/magento /usr/local/bin/magento
COPY provision/xmagento /usr/local/bin/xmagento
COPY provision/n98magerun2 /usr/local/bin/n98magerun2
COPY provision/xn98magerun2 /usr/local/bin/xn98magerun2

RUN chmod a+x /usr/local/bin/magento /usr/local/bin/xmagento /usr/local/bin/n98magerun2 /usr/local/bin/xn98magerun2

EXPOSE 80
WORKDIR /var/www/html/current
CMD bash /usr/local/bin/apache2-foreground