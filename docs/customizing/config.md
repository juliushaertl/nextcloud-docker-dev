# Config

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