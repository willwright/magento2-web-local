# Apache2 for Magento2
__THIS IS NOT FOR PRODUCTION USE__

## Example Usage
`docker-compose.yaml`
```
  web:
    image: wwright/magento2-web-local:php7.1
    volumes:
     - F:/www/docker-magento2/dev/magento:/var/www/html/current
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
* Ubuntu 16.04
* Apache 2.4.18
* PHP 7.2

### Packages
* telnet
* pip
* curl
* wget
* git
* acl
* lzop
* unzip
* nano
* composer
* n98-magerun2

### PHP Modules
* curl
* common
* gd
* mcrypt
* dev
* opcache
* json
* mysql
* readline
* xsl
* xmlrpc
* intl
* zip
* soap
* cli
* xml
* mbstring
* bcmath
* redis
* bz2
* imagick
* xdebug

### Apache Modules
* headers
* rewrite
* ssl
* expires
* php7.1

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
su -s "/bin/bash" -c "export PHP_IDE_CONFIG='serverName=aws.solesociety.com'; php -d xdebug.remote_autostart=1 bin/magento $*" www-data
```

`n98magerun2`

Runs n98-magerun2 as the proper user.
```
#!/bin/bash
su -s "/bin/bash" -c "export PHP_IDE_CONFIG='serverName=aws.solesociety.com'; php -d xdebug.remote_autostart=1 bin/magento $*" www-data
```

`xn98magerun2`

Runs n98-magerun2 as the proper user and forces XDEBUG to start. This command is used to hook XDEBUG up to command line debugging.
```
#!/bin/bash
su -s "/bin/bash" -c "export PHP_IDE_CONFIG='serverName=aws.solesociety.com'; php -d xdebug.remote_autostart=1 bin/magento $*" www-data
```

## Extensibility

## Tags
