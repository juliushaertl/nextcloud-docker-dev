<?php

// FIXME: hostname changes when container might be recreated, ideally this should be the instance id
$hostname = gethostname();

$CONFIG = array (
	//  'htaccess.RewriteBase' => '/',

	// Disable lookup server as it is not needed for our local ldap test users
	'lookup_server' => '',

	// Uncomment to create instances with minio object storage/*
	/** /
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
		),
	),

	/** /
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
	),/**/
);
