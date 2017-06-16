#!/bin/bash

DRUPAL_MAJOR_VERSION=${DRUPAL_VERSION:0:1}
TEST_RESULTS_DIRECTORY="/var/www/html/test_results"

if [ -z "$KEEP_RUNNING" ] ; then
  KEEP_RUNNING="no"
fi

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
echo -e "\n[Downloading Drupal]\n"
curl -fSL "https://ftp.drupal.org/files/projects/drupal-${DRUPAL_VERSION}.tar.gz" -o drupal.tar.gz
tar -xz --strip-components=1 -f drupal.tar.gz
rm drupal.tar.gz
chown -R www-data:www-data sites modules themes

# Start web and sql servers.
echo -e "\n[Starting web server]\n"
cp 000-default.conf /etc/apache2/sites-enabled/000-default.conf
a2enmod rewrite
service apache2 start

echo -e "\n[Starting sql server]\n"
service mysql start

# Install Drupal instance.
echo -e "\n[Installing Drupal]\n"
mysql -uroot -proot -e "create database drupal;"
cp settings.php sites/default/settings.php
drush site-install standard --account-name=admin --account-pass=admin -y
chmod -R 777 sites/default/files

# Install Drupal dependencies. Drupal 8 only.
if (( ${DRUPAL_MAJOR_VERSION} == 8 )) ; then
  echo -e "\n[Install Drupal dependencies]\n"
  composer install
fi

# Download needed modules.
echo -e "\n[Downloading modules]\n"
for module in ${MODULES_DOWNLOAD//,/ }
do
  drush dl -y ${module} --destination=${MODULES_DIR}
done

# Enable needed modules.
echo -e "\n[Enabling modules]\n"
for module in ${MODULES_ENABLE//,/ }
do
  drush en -y ${module}
done

# Run all scripts from "custom_scripts" folder.
for file in ./custom_scripts/*.sh
do
  if [ -e "$file" ]; then
    echo -e "\n[Running custom scripts: ${file}]\n"
    . ${file}
  fi
done

# Run simpletest tests.
echo -e "\n[Running tests]\n"
drush en -y simpletest
chown www-data:www-data -R ${TEST_RESULTS_DIRECTORY}
sudo -u www-data php ${SIMPLETEST_SCRIPT} --xml ${TEST_RESULTS_DIRECTORY} "${SIMPLETEST_GROUPS}"

# Keep container running (for debugging purposes).
if [ "${KEEP_RUNNING}" == "yes" ] ; then
  echo -e "\n[Keeping running container for debugging purposes]\n"
  tail -f /dev/null
fi
