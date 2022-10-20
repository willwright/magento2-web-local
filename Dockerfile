FROM ubuntu:22.04

MAINTAINER Will Wright <will@magesmith.com>

# disable interactive functions
ARG DEBIAN_FRONTEND=noninteractive

RUN export LC_ALL=en_US.UTF-8 && export LANG=en_US.UTF-8 && \
    apt-get update && \
    apt-get install -y --allow-unauthenticated software-properties-common ntp build-essential build-essential binutils \
    zlib1g-dev language-pack-en-base curl wget git acl lzop unzip nano && \
    add-apt-repository ppa:ondrej/php && \
    apt-get update && \
    apt-get install -y --allow-unauthenticated telnet openssh-server mysql-client mcrypt expat xsltproc python3-pip nginx

RUN apt-get install -y --allow-unauthenticated php8.1-fpm php8.1-cli php8.1 php8.1-curl php8.1-common php8.1-gd \
    php8.1-dev php8.1-opcache php8.1-mysql php8.1-readline php8.1-xsl php8.1-xmlrpc \
    php8.1-intl php8.1-zip php8.1-soap php8.1-cli php8.1-xml php8.1-mbstring php8.1-bcmath php8.1-redis \
    php8.1-bz2 php8.1-imagick php8.1-xdebug \
    && phpenmod mcrypt xsl imagick \
    && adduser --ui 501 --ingroup www-data --shell /bin/bash --home /home/builder builder

#
#   Install Composer
#
RUN curl -sSL https://getcomposer.org/download/2.2.18/composer.phar -o /usr/bin/composer \
    && chmod +x /usr/bin/composer

#
#   Install n98-magerun
#
RUN cd ~ && wget https://files.magerun.net/n98-magerun2.phar && \
    chmod +x ./n98-magerun2.phar && \
    cp ./n98-magerun2.phar /usr/local/bin/

#
#   Install supervisor
#
RUN pip install supervisor

RUN echo "root:password123" | chpasswd

#
#   Install ionCube
#
#COPY ioncube /usr/lib/php/20151012
#COPY etc/php/7.2/mods-available/ioncube.ini /etc/php/7.2/mods-available/ioncube.ini
#RUN phpenmod ioncube

#
#   Inject config files at the end to optimize build cache
#
COPY etc/nginx/sites-available/magento /etc/nginx/sites-available/magento
COPY etc/php/8.1/fpm/php.ini /etc/php/8.1/fpm/php.ini
COPY etc/php/8.1/cli/php.ini /etc/php/8.1/cli/php.ini
COPY etc/supervisor/supervisord.conf /etc/supervisor/supervisord.conf

#
#   Xdebug setup
#
COPY etc/php/8.1/cli/conf.d/20-xdebug.ini /etc/php/8.1/cli/conf.d/20-xdebug.ini
COPY etc/php/8.1/fpm/conf.d/20-xdebug.ini /etc/php/8.1/fpm/conf.d/20-xdebug.ini
RUN touch /var/log/xdebug.log && chmod a+rwx /var/log/xdebug.log

RUN mkdir -p /run/php/

RUN unlink /etc/nginx/sites-enabled/default
RUN ln -s /etc/nginx/sites-available/magento /etc/nginx/sites-enabled/magento

RUN chown -R builder:www-data /var/www/html

COPY provision/magento /usr/local/bin/magento
COPY provision/xmagento /usr/local/bin/xmagento
COPY provision/n98magerun2 /usr/local/bin/n98magerun2
COPY provision/xn98magerun2 /usr/local/bin/xn98magerun2

RUN chmod a+x /usr/local/bin/magento /usr/local/bin/xmagento /usr/local/bin/n98magerun2 /usr/local/bin/xn98magerun2

EXPOSE 80
WORKDIR /var/www/html/current
CMD ["/usr/local/bin/supervisord","-c","/etc/supervisor/supervisord.conf"]