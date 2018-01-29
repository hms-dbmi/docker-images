<?php
array_shift($argv);
$datasources = $argv;
$unspec = [];
foreach ($datasources as $ds) {
	if ($_ENV['ORACLE'] == 1) {
		echo "db.type=oracle\n";
		echo "db.driver=oracle.jdbc.driver.OracleDriver\n";
		echo "db.url=jdbc:oracle:thin:@" . $_ENV['DB_HOST'] . ":" . $_ENV['DB_PORT'] . ($_ENV['DB_ORASVC'] ? "/" . $_ENV['DB_ORASVC'] : ":" . $_ENV['DB_ORASID']) . "\n";
		echo "db.server=" . $_ENV['DB_HOST'] . ":" . $_ENV['DB_PORT'] . ($_ENV['DB_ORASVC'] ? "/" . $_ENV['DB_ORASVC'] : ":" . $_ENV['DB_ORASID']) . "\n";
	} else {
		/* TODO add postres */
	}

	echo "db.username=" . $ds . "\n";
	if (isset($_ENV[strtoupper($ds)])) {
		echo "db.password=" . $_ENV[strtoupper($ds)] . "\n";
	} else {
		echo "db.password=demouser\n";
	}
	echo "db.project=demo\n";
}

