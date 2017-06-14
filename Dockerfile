FROM ubuntu:14.04

ENV DEBIAN_FRONTEND="noninteractive"

# Install utilities and LAMP stack.
RUN apt-get update && \
    echo "mysql-server-5.5 mysql-server/root_password password root" | debconf-set-selections && \
    echo "mysql-server-5.5 mysql-server/root_password_again password root" | debconf-set-selections && \
    apt-get install git nano curl apache2 mysql-server-5.5 php5-mysql php5 php5-cli php5-gd php5-curl libapache2-mod-php5 php5-mcrypt -y && \
    apt-get autoclean -y && \
    apt-get autoremove -y

# Install composer.
RUN php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" && \
    php -r "if (hash_file('SHA384', 'composer-setup.php') === '669656bab3166a7aff8a7506b8cb2d1c292f042046c5a994c43155c0be6190fa0355160742ab2e1c88d40d5be660b410') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;" && \
    php composer-setup.php && \
    php -r "unlink('composer-setup.php');" && \
    mv composer.phar /usr/local/bin/composer

ENV PATH=~/.composer/vendor/bin:$PATH"

# Install drush.
RUN composer global require drush/drush:8.1.11

# Create temporary directory for mounted files.
WORKDIR /var/www/html

# Copy conf files.
COPY conf/000-default.conf 000-default.conf
COPY conf/settings.php settings.php

# Start container.
COPY startup.sh startup.sh
CMD ["/bin/bash", "startup.sh"]
