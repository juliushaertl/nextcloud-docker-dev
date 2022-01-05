<?php

// set the hostname to the VIRTUAL_HOST set for the docker container, otherwise fallback to the docker hostname
$hostname = gethostname();
$virtualHost = isset($_ENV['VIRTUAL_HOST']) ? $_ENV['VIRTUAL_HOST'] : '';
$virtualHost = explode(".", $virtualHost);
if (count($virtualHost) > 0) {
	$hostname = array_shift($virtualHost);
}

$CONFIG = array (
	//  'htaccess.RewriteBase' => '/',

	// Uncomment to create instances with minio object storage
	/* */
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
		),
	),
	/* */

	/* /
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
	/* */
);
