# Start with Ubuntu base
FROM ubuntu

# Credit
MAINTAINER Daniel Poulin

# Install some basics
RUN apt-get update
RUN apt-get install -y vim ntp

# Install apache and php5
RUN apt-get install -y apache2
RUN apt-get install -y php5 php5-mysql php5-gd php5-curl libapache2-mod-php5

# Set environment variables
ENV APACHE_RUN_USER www-data
ENV APACHE_RUN_GROUP www-data
ENV APACHE_LOG_DIR /var/log/apache2

# Make sure all the desired apache modules are on
RUN a2enmod ssl headers rewrite vhost_alias && apache2ctl restart

# Disable default site and replace with our own
ADD dynamic-vhost.conf /etc/apache2/sites-available/dynamic
ADD setDocRoot.php /etc/apache2/includes/
RUN a2dissite default && a2ensite dynamic && service apache2 restart

# Clean up after install
RUN apt-get clean && rm -rf /var/lib/apt/lists/*

# Run apache on standard ports
EXPOSE 80 443

CMD ["/usr/sbin/apache2ctl", "-D", "FOREGROUND"]
