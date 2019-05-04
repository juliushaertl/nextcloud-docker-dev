	'objectstore' => [
		'class' => 'OC\Files\ObjectStore\S3',
		'arguments' => [
			// replace with your bucket
			'bucket' => 'nextcloud',
			'autocreate' => true,
			'key'    => 'dummy',
			'secret' => 'dummyj',
			'hostname' => 's3',
			'port' => 4569,
			'use_ssl' => false,
			'use_path_style'=>true
		],
	],
