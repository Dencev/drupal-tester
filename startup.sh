#!/bin/bash

DRUPAL_MAJOR_VERSION=${DRUPAL_VERSION:0:1}
TEST_RESULTS_DIRECTORY="/var/www/html/test_results"

case ${DRUPAL_MAJOR_VERSION} in
  7)
    MODULES_DIR="sites/all/modules/contrib"
    SIMPLETEST_SCRIPT="./scripts/run-tests.sh"
    ;;
  8)
    MODULES_DIR="modules/contrib"
    SIMPLETEST_SCRIPT="./core/scripts/run-tests.sh"
    ;;
  *)
    echo "invalid Drupal version"
    exit 1
esac

mkdir -p ${MODULES_DIR}

# Download Drupal.
curl -fSL "https://ftp.drupal.org/files/projects/drupal-${DRUPAL_VERSION}.tar.gz" -o drupal.tar.gz
tar -xz --strip-components=1 -f drupal.tar.gz
rm drupal.tar.gz
chown -R www-data:www-data sites modules themes

# Start web and sql servers.
cp 000-default.conf /etc/apache2/sites-enabled/000-default.conf
a2enmod rewrite
service apache2 start
service mysql start

# Install Drupal instance.
mysql -uroot -proot -e "create database drupal;"
cp settings.php sites/default/settings.php
drush site-install standard --account-name=admin --account-pass=admin -y
chmod -R 777 sites/default/files

# Install Drupal dependencies. Drupal 8 only.
if (( ${DRUPAL_MAJOR_VERSION} == 8 )) ; then
  composer install
fi

# Download needed modules.
for module in ${MODULES_DOWNLOAD//,/ }
do
  drush dl -y ${module} --destination=${MODULES_DIR}
done

# Enable needed modules.
for module in ${MODULES_ENABLE//,/ }
do
  drush en -y ${module}
done

# Run simpletest tests.
drush en -y simpletest
chown www-data:www-data -R ${TEST_RESULTS_DIRECTORY}
sudo -u www-data php ${SIMPLETEST_SCRIPT} --xml ${TEST_RESULTS_DIRECTORY} "${SIMPLETEST_GROUPS}"

## Keep container running (for debugging purposes).
#tail -f /dev/null
