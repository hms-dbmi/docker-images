<?php
array_shift($argv);
$schemas = $argv;
$unspec = [];
foreach ($schemas as $schema) {
	if ($_ENV['ORACLE'] == 1) {
		echo "CREATE USER $schema IDENTIFIED BY " . (isset($_ENV[strtoupper($schema)]) ? $_ENV[strtoupper($schema)] : "demouser") . " \n";
		echo "DEFAULT TABLESPACE \"I2B2\";\n";

		echo "GRANT CREATE TRIGGER TO $schema;\n";
		echo "GRANT CREATE SEQUENCE TO $schema;\n";
		echo "GRANT CREATE TABLE TO $schema;\n";
		echo "GRANT CREATE PROCEDURE TO $schema;\n";
		echo "GRANT CREATE VIEW TO $schema;\n";
		echo "GRANT CREATE ROLE TO $schema;\n";
		/* Not discussed in i2b2-data installation documentation -Andre */
		echo "GRANT CREATE SESSION TO $schema;\n";
		echo "GRANT CREATE TYPE TO $schema;\n";
		echo "ALTER USER $schema QUOTA UNLIMITED ON I2B2;\n";
	} else {
		/* TODO add postres */
	}

}
?>
