'objectstore' => [
	'class' => 'OC\\Files\\ObjectStore\\S3',
	'arguments' => [
		'bucket' => 'nextcloud',
		'key' => '123',
		'secret' => 'abc',
		'hostname' => 's3',
		'port' => '4567',
		'use_ssl' => false,
		'use_path_style' => true,
	],
],