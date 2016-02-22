FROM ubuntu:14.04
MAINTAINER Tarik Abouali <aboualitarik@gmail.com>

# Keep upstart from complaining
RUN dpkg-divert --local --rename --add /sbin/initctl
RUN ln -sf /bin/true /sbin/initctl
#ADD mysql.list /etc/apt/sources.list.d/

# Update
RUN apt-get update
RUN apt-get -y upgrade

# Basic Requirements
RUN DEBIAN_FRONTEND=noninteractive apt-get -y install mysql-server-5.6 apache2 libapache2-mod-php5 php5-mysql php-apc python-setuptools curl git unzip vim-tiny

# App Requirements
RUN DEBIAN_FRONTEND=noninteractive apt-get -y -q install php5-curl php5-gd php5-intl php-pear php5-imagick php5-imap php5-mcrypt php5-memcache php5-ming php5-ps php5-pspell php5-recode php5-sqlite php5-tidy php5-xmlrpc php5-xsl

# mysql config
ADD my.cnf /etc/mysql/conf.d/my.cnf
RUN chmod 664 /etc/mysql/conf.d/my.cnf

# apache config
ENV APACHE_RUN_USER www-data
ENV APACHE_RUN_GROUP www-data
ENV APACHE_LOG_DIR /var/log/apache2
RUN chown -R www-data:www-data /var/www/
RUN sed -e 's/DirectoryIndex/DirectoryIndex index.php/' < /etc/apache2/mods-enabled/dir.conf > /tmp/foo.sed
RUN mv /tmp/foo.sed /etc/apache2/mods-enabled/dir.conf
#RUN php5enmod mcrypt
RUN a2enmod rewrite
ADD 000-default.conf /etc/apache2/sites-available/000-default.conf
RUN chmod 0644 /etc/apache2/sites-available/000-default.conf

# Composer
RUN curl -sS https://getcomposer.org/installer | php && \
    mv composer.phar /usr/local/bin/composer && \
    ln -s ~/.composer/vendor/bin/* /usr/local/bin/

# php config
RUN sed -i -e "s/upload_max_filesize\s*=\s*2M/upload_max_filesize = 100M/g" /etc/php5/apache2/php.ini
RUN sed -i -e "s/post_max_size\s*=\s*8M/post_max_size = 100M/g" /etc/php5/apache2/php.ini
RUN sed -i -e "s/short_open_tag\s*=\s*Off/short_open_tag = On/g" /etc/php5/apache2/php.ini

# fix for php5-mcrypt
RUN /usr/sbin/php5enmod mcrypt

# Supervisor Config
RUN mkdir /var/log/supervisor/
RUN /usr/bin/easy_install supervisor
RUN /usr/bin/easy_install supervisor-stdout
ADD ./supervisord.conf /etc/supervisord.conf

# Initialization Startup Script
ADD ./start.sh /start.sh
RUN chmod 755 /start.sh

EXPOSE 3306
EXPOSE 80

CMD ["/bin/bash", "/start.sh"]
