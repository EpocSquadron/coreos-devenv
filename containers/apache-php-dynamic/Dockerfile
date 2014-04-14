# Start with Ubuntu base
FROM ubuntu:12.10

# Credit
MAINTAINER Daniel Poulin

# Install some basics
RUN apt-get update

# Install apache and php5
RUN apt-get install -y apache2
RUN apt-get install -y php5 \
	php5-mysql \
	php5-gd \
	php5-curl \
	php5-mcrypt \
	php5-xdebug \
	php-apc \
	libapache2-mod-php5

# Clean up after install
RUN apt-get clean && rm -rf /var/lib/apt/lists/*

# Set environment variables
ENV APACHE_RUN_USER www-data
ENV APACHE_RUN_GROUP www-data
ENV APACHE_LOG_DIR /var/log/apache2

# Make sure all the desired apache modules are on
RUN a2enmod ssl headers rewrite vhost_alias && apache2ctl restart

# Disable default site and replace with our own
ADD dynamic-vhost.conf /etc/apache2/sites-available/dynamic
ADD setDocRoot.php /etc/apache2/includes/
RUN a2dissite default && a2ensite dynamic

# Set the default timezone
ADD timezone.ini /etc/php5/conf.d/timezone.ini

# Set up remote debugging for xdebug
ADD xdebug.ini /etc/php5/conf.d/xdebug.ini
RUN echo 'zend_extension="'$(find / -name 'xdebug.so' 2> /dev/null)'"' >> /etc/php5/conf.d/xdebug.ini

# Run apache on standard ports
EXPOSE 80 443

ENTRYPOINT ["/usr/sbin/apache2ctl"]

CMD ["-D", "FOREGROUND"]
