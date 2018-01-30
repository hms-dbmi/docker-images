<?php
array_shift($argv);
$schemas = $argv;
foreach ($schemas as $schema) {
	if ($_ENV['ORACLE'] == 1) {
		echo "DROP USER $schema CASCADE;\n";
	} else {
		/* TODO add postres */
	}

}
?>
