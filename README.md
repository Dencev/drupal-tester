# Docker image for testing Drupal projects

## Run tests
Build container:
`docker build -t drupal-tester .`

Run container:
`docker-compose -f docker-compose-d{DRUPAL_VERSION}.yml up && docker-compose -f docker-compose-d{DRUPAL_VERSION}.yml down`

Remove container:
`docker rmi drupal-tester`

Where `{DRUPAL_VERSION}` can be `7` or `8` (see `docker-compose-d7.yml` and `docker-compose-d8.yml` example files).

## Configuration

Available environmental variables:

 * `DRUPAL_VERSION` - specific version of Drupal.
 * `MODULES_DOWNLOAD` - a list of modules to download (by Drush) separated by comma. Example: `module_name,[...]`
 * `MODULES_ENABLE` a list of module to enable (by Drush) separated by comma. Example: `module_name,[...]`
 * `SIMPLETEST_GROUPS` - a list of simpletest groups to run separated by comma. Example: `Group 1,[...]`
