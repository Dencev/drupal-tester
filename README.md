# Docker image for testing Drupal projects
This docker container allows you to run tests without having LAMP stack installed on your host machine.

## Why?
1. For local usage. You don't need to worry about your local Drupal installation to run tests. Just specify what modules you want to check and run this container.
2. For usage on a CI servers.

## Requirements
 * Docker
 * Docker compose (optionally)

## Run tests (local usage)
For local usage it's more comfortable to use `docker-compose`. With this tool you don't need to write long cli command to run container.

1. Build container: `docker build -t drupal-tester .`
2. Run it: `docker-compose up && docker-compose down`
3. Remove container: `docker rmi drupal-tester`

## Run tests (CI usage)
If you want to run tests continuously on your CI server then most likely you will want to override some default values defined in `docker-compose.yml` file. In this case you can run container with `docker` command and specify all the variables manually.

1. Build container: `docker build -t drupal-tester .`
2. Run it: `docker run -v $(pwd)/test_results:/var/www/html/test_results -v $(pwd)/custom_scripts:/var/www/html/custom_scripts -e KEEP_RUNNING=no -e DRUPAL_VERSION=8.3.2 -e MODULES_DOWNLOAD=module-version -e MODULES_ENABLE=module -e SIMPLETEST_GROUPS=module_test_group -e SIMPLETEST_CONCURRENCY=1 drupal-tester`
3. Remove container: `docker rmi drupal-tester`

## Available variables:

 * `KEEP_RUNNING` - specify `yes` if you want to keep container running when tests will be executed. Use for debugging purposes only. Default value is `no`.
 * `DRUPAL_VERSION` - specific version of Drupal. Supported Drupal 7 and Drupal 8. Example: `8.3.2`.
 * `MODULES_DOWNLOAD` - a list of modules to download (by Drush) separated by comma. Example: `module_name-module_version,[...]`.
 * `MODULES_ENABLE` a list of modules to enable (by Drush) separated by comma. Example: `module_name,[...]`.
 * `SIMPLETEST_GROUPS` - a list of simpletest groups to run separated by comma. Example: `Group 1,[...]`.
 * `SIMPLETEST_CONCURRENCY` - amount of test runners to test code in parallel. Default value is `1`.

## Features
### Test results
All tests results will be placed into `test_results` directory. Don't forget to mount this directory inside of a container. See `docker-compose.yml` example file fore more information.

### Custom scripts
You can perform some actions/commands before tests execution. Just put your `*.sh` files to `custom_scripts` directory and they will be executed right before container will run tests. Don't forget to mount this directory inside of a container. See `docker-compose.yml` example file fore more information.

## License
GPLv3. See LICENSE file.
