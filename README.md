# Web Container for Magento2
__THIS IS NOT FOR PRODUCTION USE__

## Example Usage
`docker-compose.yaml`
```
  web:
    image: wwright/magento2-web-local
    volumes:
     - ./magento:/var/www/html/current
    environment:
      - XDEBUG_CONFIG=remote_host=host.docker.internal remote_enable=1
      - PHP_IDE_CONFIG=serverName=local.magento2.com
    depends_on:
     - redis-cache
     - redis-fpc
     - redis-session
     - db
```

## Documentation
### Services
* Ubuntu 22.04
* nginx 1.18.0
* php-fpm
* PHP 8.1.8

### PHP Modules
* bcmath 
* bz2 
* calendar 
* Core 
* ctype 
* curl 
* date 
* dom 
* exif 
* FFI 
* fileinfo 
* filter 
* ftp 
* gd 
* gettext 
* hash
* iconv 
* igbinary 
* imagick 
* intl 
* json 
* libxml 
* mbstring 
* mysqli 
* mysqlnd 
* openssl 
* pcntl 
* pcre 
* PDO 
* pdo_mysql 
* Phar 
* posix 
* readline 
* redis 
* Reflection 
* session 
* shmop 
* SimpleXML 
* soap 
* sockets 
* sodium 
* SPL 
* standard 
* sysvmsg 
* sysvsem 
* sysvshm 
* tokenizer 
* xdebug 
* xml 
* xmlreader 
* xmlrpc 
* xmlwriter 
* xsl 
* Zend OPcache 
* zip 
* zlib

## Defaults
HTTP listen port 80

HTTPS listen port 443

`DocumentRoot /var/www/html/current/pub/`

## Usage
There are four helper scripts that come pre-installed and registerd in $PATH
* `magento`
* `xmagento`
* `n98magerun2`
* `xn98magerun2`

`magento`

Runs the magento CLI as the proper user. 
```
#!/bin/bash
su -s "/bin/bash" -c "bin/magento $*" www-data
```

`xmagento`

Runs the magento CLI as the proper user and forces XDEBUG to start. This command is used to hook XDEBUG up to command line debugging.
```
#!/bin/bash
su -s "/bin/bash" -c "export PHP_IDE_CONFIG='serverName=local.magento2.com'; php -d xdebug.remote_autostart=1 bin/magento $*" www-data
```

`n98magerun2`

Runs n98-magerun2 as the proper user.
```
#!/bin/bash
su -s "/bin/bash" -c "export PHP_IDE_CONFIG='serverName=local.magento2.com'; php -d xdebug.remote_autostart=1 bin/magento $*" www-data
```

`xn98magerun2`

Runs n98-magerun2 as the proper user and forces XDEBUG to start. This command is used to hook XDEBUG up to command line debugging.
```
#!/bin/bash
su -s "/bin/bash" -c "export PHP_IDE_CONFIG='serverName=local.magento2.com'; php -d xdebug.remote_autostart=1 bin/magento $*" www-data
```

## Extensibility
Configuration override locations:
* `/etc/nginx/sites-available/magento`
* `/etc/php/8.1/cli/php.ini`
* `/etc/php/8.1/cli/conf.d/20-xdebug.ini`
* `/etc/php/8.1/fpm/php.ini`
* `/etc/php/8.1/fpm/conf.d/20-xdebug.ini`
