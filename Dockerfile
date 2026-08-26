FROM ubuntu:24.04

# disable interactive functions
ARG DEBIAN_FRONTEND=noninteractive

RUN export LC_ALL=en_US.UTF-8 && export LANG=en_US.UTF-8 && \
    apt-get update && \
    apt-get install -y --allow-unauthenticated software-properties-common ntp build-essential build-essential binutils \
    zlib1g-dev language-pack-en-base curl wget git acl lzop unzip nano && \
    add-apt-repository ppa:ondrej/php && \
    apt-get update && \
    apt-get install -y --allow-unauthenticated telnet openssh-server mysql-client mcrypt expat xsltproc supervisor nginx

RUN apt-get install -y --allow-unauthenticated php8.4-fpm php8.4-cli php8.4 php8.4-curl php8.4-common php8.4-gd \
    php8.4-dev php8.4-opcache php8.4-mysql php8.4-readline php8.4-xsl php8.4-xmlrpc \
    php8.4-intl php8.4-zip php8.4-soap php8.4-cli php8.4-xml php8.4-mbstring php8.4-bcmath php8.4-redis \
    php8.4-bz2 php8.4-imagick php8.4-xdebug \
    && phpenmod mcrypt xsl imagick \
    && adduser --ui 501 --ingroup www-data --shell /bin/bash --home /home/builder builder

#
#   Install Composer
#
RUN curl -sSL https://getcomposer.org/download/2.10.2/composer.phar -o /usr/bin/composer \
    && chmod +x /usr/bin/composer

#
#   Install n98-magerun
#
RUN cd ~ && wget https://files.magerun.net/n98-magerun2.phar && \
    chmod +x ./n98-magerun2.phar && \
    cp ./n98-magerun2.phar /usr/local/bin/

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
COPY etc/php/8.4/fpm/php.ini /etc/php/8.4/fpm/php.ini
COPY etc/php/8.4/cli/php.ini /etc/php/8.4/cli/php.ini
COPY etc/supervisor/supervisord.conf /etc/supervisor/supervisord.conf

#
#   Xdebug setup
#
COPY etc/php/8.4/cli/conf.d/20-xdebug.ini /etc/php/8.4/cli/conf.d/20-xdebug.ini
COPY etc/php/8.4/fpm/conf.d/20-xdebug.ini /etc/php/8.4/fpm/conf.d/20-xdebug.ini
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

#
#   Log nginx to stdout
#
# RUN ln -sf /dev/stdout /var/log/nginx/access.log && ln -sf /dev/stderr /var/log/nginx/error.log

EXPOSE 80
WORKDIR /var/www/html/current
CMD ["/usr/bin/supervisord","-c","/etc/supervisor/supervisord.conf"]