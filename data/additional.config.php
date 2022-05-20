<?php
// FIXME: Move everything except the last part to the containers
// set the hostname to the VIRTUAL_HOST set for the docker container, otherwise fallback to the docker hostname
$hostname = gethostname();
$primary = isset($_ENV['PRIMARY']) ? $_ENV['PRIMARY'] : '';
$virtualHost = isset($_ENV['VIRTUAL_HOST']) ? $_ENV['VIRTUAL_HOST'] : '';
$virtualHost = explode(".", $virtualHost);
if (count($virtualHost) > 0) {
	$hostname = array_shift($virtualHost);
}

$CONFIG = [];
if ($primary === 'minio') {
	$CONFIG += [
		'objectstore' =>
		array (
			'class' => 'OC\\Files\\ObjectStore\\S3',
			'arguments' =>
			array (
				'bucket' => 'nc-' . $hostname,
				'key' => 'nextcloud',
				'secret' => 'nextcloud',
				'hostname' => 'minio',
				'port' => '9000',
				'use_ssl' => false,
				'use_path_style' => true,
				'autocreate' => true,
				'verify_bucket_exists' => true,
			),
		)
	];
}

if ($primary === 'minio-multibucket') {
	$CONFIG += [
		'objectstore_multibucket' => array(
			'class' => 'OC\\Files\\ObjectStore\\S3',
			'arguments' => array(
				// optional, defaults to 64
				'num_buckets' => 64,
				// n integer in the range from 0 to (num_buckets-1) will be appended
				'bucket' => 'nextcloud_',
				'bucket' => 'nc-' . $hostname,
				'key' => 'nextcloud',
				'secret' => 'nextcloud',
				'hostname' => 'minio',
				'port' => '9000',
				'use_ssl' => false,
				'use_path_style' => true,
			),
		),
	];
}

// Useful config values during development
$CONFIG += array(
	'debug' => true,
	'loglevel' => 2,

	//  'htaccess.RewriteBase' => '/',
	'log_query' => false,
	'query_log_file' => '/var/www/html/data/query.log',

	'diagnostics.logging' => false,
	'diagnostics.logging.threshold' => 0,
	'log.condition' => [
        'apps' => ['diagnostics', 'admin_audit'],
	],
);
