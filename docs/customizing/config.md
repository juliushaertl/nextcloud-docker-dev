# Config

## PHP Version

The PHP version can be changed by setting the `PHP_VERSION` environment variable in your local `.env` file. If no value is set the minimum required version for the current Nextcloud version will be used depending on the Nextcloud container.

```bash
# For using PHP 8.3
PHP_VERSION=83
```

The variable supports the following values:

- PHP 7.1: `71`
- PHP 7.2: `72`
- PHP 7.3: `73`
- PHP 7.4: `74`
- PHP 8.0: `80`
- PHP 8.1: `81`
- PHP 8.2: `82`
- PHP 8.3: `83` (currently the xdebug and imagick php extensions are not available for this version)

## Nextcloud config.php

The config.php file of Nextcloud is pre-seeded with lots of configuration values. In order to change them you can place a personal config.php file in `data/shared/config.php`. This file will be included after the default config.php file for all Nextcloud containers.

```php
<?php
$CONFIG = [
    'loglevel' => 2,
    'log_query' => true,
    'log.condition' => [
        'apps' => ['myapp'],
    ],
];  
```
