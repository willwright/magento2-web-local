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

RUN apt-get install -y --allow-unauthenticated php7.4-fpm php7.4-cli php7.4 php7.4-curl php7.4-common php7.4-gd \
    php7.4-dev php7.4-opcache php7.4-mysql php7.4-readline php7.4-xsl php7.4-xmlrpc \
    php7.4-intl php7.4-zip php7.4-soap php7.4-cli php7.4-xml php7.4-mbstring php7.4-bcmath php7.4-redis \
    php7.4-bz2 php7.4-imagick php7.4-xdebug \
    && phpenmod mcrypt xsl imagick \
    && adduser --ui 501 --ingroup www-data --shell /bin/bash --home /home/builder builder

#
#   Install Composer
#
RUN curl -sSL https://getcomposer.org/download/1.10.26/composer.phar -o /usr/bin/composer \
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
COPY etc/php/7.4/fpm/php.ini /etc/php/7.4/fpm/php.ini
COPY etc/php/7.4/cli/php.ini /etc/php/7.4/cli/php.ini
COPY etc/supervisor/supervisord.conf /etc/supervisor/supervisord.conf

#
#   Xdebug setup
#
COPY etc/php/7.4/cli/conf.d/20-xdebug.ini /etc/php/7.4/cli/conf.d/20-xdebug.ini
COPY etc/php/7.4/fpm/conf.d/20-xdebug.ini /etc/php/7.4/fpm/conf.d/20-xdebug.ini
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