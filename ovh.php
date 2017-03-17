#!/usr/bin/php
<?php
// https://github.com/ovh/php-ovh/releases/download/v2.0.1/php-ovh-2.0.1-with-dependencies.tar.gz
require __DIR__ . '/vendor/autoload.php';
require __DIR__ . '/perso.php';
use \Ovh\Api;

if ($argc == 1) {
	echo 'https://api.ovh.com/createToken/';
	echo    '?GET=/cloud/project/' . $projectId . '/instance*';
	echo   '&POST=/cloud/project/' . $projectId . '/instance';
	echo '&DELETE=/cloud/project/' . $projectId . '/instance/*';
	echo    '&GET=/cloud/project/' . $projectId . '/credit*';
	echo '&GET=/me/api/application';
	echo '&GET=/me/api/application/*';
	echo '&DELETE=/me/api/application/*';
	echo "\n";
	exit(0);
}

foreach (file(__DIR__ . '/credentials.txt') as $lineNumber => $lineContent) {
	if ($lineContent == "\n") continue;
	if (isset($var)) {
		eval("$var=substr('$lineContent', 0, strlen('$lineContent') - 1);");
		unset($var);
		continue;
	}
	if     ($lineContent == "Application Key\n")    $var='$applicationKey';
	elseif ($lineContent == "Application Secret\n") $var='$applicationSecret';
	elseif ($lineContent == "Consumer Key\n")       $var='$consumer_key';
}
$ovh = new Api($applicationKey, $applicationSecret, 'ovh-eu', $consumer_key);

try {
	if ($argc > 2) {
		if ($argv[2] == 'list') {
			if ($argv[1] == 'instance')    listInstances();
			if ($argv[1] == 'application') listApplications();
		}
		if ($argv[2] == 'show') {
			if ($argv[1] == 'credit') showCredits();
		}
		if ($argc > 3) {
			if ($argv[2] == 'create') {
				if ($argv[1] == 'instance') createInstance($argv[3]);
			}
			if ($argv[2] == 'delete') {
				if ($argv[1] == 'instance')    deleteInstance($argv[3]);
				if ($argv[1] == 'application') deleteApplication($argv[3]);
			}
		}
	}
} catch (GuzzleHttp\Exception\ClientException $e) {
	echo $e->getResponse()->getBody()->getContents() . "\n";
	exit(5);
} catch (Exception $e) {
	echo $e->getMessage(),"\n";
	exit(6);
}


function createInstance($name) {
	global $ovh, $projectId;
	$instance = $ovh->post('/cloud/project/' . $projectId . '/instance', array(
		'name' => $name,
		'flavorId' => '98c1e679-5f2c-4069-b4da-4a4f7179b758', // ssd
		'region' => 'GRA1',
		'imageId' => '502af20c-d456-4ffb-888d-2d0787796c5e',  // debian8
		'sshKeyId' => '55473979644746696247553d',             // Portable
		'monthlyBilling' => false,
		'groupId' => NULL,
		'networks' => NULL,
		'userData' => '#!/bin/bash
cd /var/
/bin/cat <<EO_TGZ_64 | /usr/bin/base64 -d | /bin/tar zx
' . shell_exec('tar cz "initvm" | base64') . '
EO_TGZ_64
/var/initvm/0_init.sh',
	));

	while ($instance['status'] != 'ACTIVE') {
		sleep(5);
		$instance = $ovh->get('/cloud/project/' . $projectId . '/instance/' . $instance['id']);
	}

	foreach($instance['ipAddresses'] as $ipAddress) echo $ipAddress['ip'] . "\n";
}


function listInstances() {
	global $ovh, $projectId;
	foreach ($ovh->get('/cloud/project/' . $projectId . '/instance') as $instance) {
//print_r($instance);
		echo $instance['name'] . ' (' . $instance['id'] . ') : ' . $instance['status'];
		foreach ($instance['ipAddresses'] as $ipAddress) echo ' ' . $ipAddress['ip'];
		echo "\n";
	}
}


function deleteInstance($instanceId) {
	global $ovh, $projectId;
	print_r($ovh->delete('/cloud/project/' . $projectId . '/instance/' . $instanceId));
}


function listApplications() {
	global $ovh;
	foreach ($ovh->get('/me/api/application') as $application) {
		$applicationDetails = $ovh->get('/me/api/application/' . $application);
		echo '- ' . $applicationDetails['applicationId'] . ' : ' . $applicationDetails['name'] . ' - ' . $applicationDetails['description'] . ' (' . $applicationDetails['status'] . ")\n";
	}
}


function deleteApplication($applicationId) {
	global $ovh;
	if ($applicationId == 'all') {
		foreach ($ovh->get('/me/api/application') as $application) {
			deleteApplication($application);
		}
		return 0;
	}
	print_r($ovh->delete('/me/api/application/' . $applicationId));
}


function showCredits() {
	global $ovh, $projectId;
	foreach ($ovh->get('/cloud/project/' . $projectId . '/credit') as $creditId) {
		print_r($ovh->get('/cloud/project/' . $projectId . '/credit/' . $creditId));
	}
}
?>
