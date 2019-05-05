<?php
$CONFIG = array (
    
	'trusted_domains' => [
		0 => 'localhost',
		1 => 'local.dev.bitgrid.net',
		2 => 'nextcloud.local.dev.bitgrid.net',
		3 => 'nextcloud-federated.local.dev.bitgrid.net',
		// docker internal ip / hostname required for blackfire support
		4 => '192.168.21.8',
		5 => 'nextcloud'
	],

	'overwrite.cli.url' => 'https://nextcloud.local.dev.bitgrid.net',


	'htaccess.RewriteBase' => '/',
	
	'overwriteprotocol' => 'https',

  );