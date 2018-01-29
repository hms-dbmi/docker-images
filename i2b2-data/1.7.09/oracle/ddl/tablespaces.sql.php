<?php
array_shift($argv);
$commands = $argv;

foreach($commands as $command) {
    if($command == "create") {
        if (isset($_ENV['ORACLE_TABLESPACES_DIR'])) {
            echo "ALTER SYSTEM SET DB_CREATE_FILE_DEST = '$_ENV[ORACLE_TABLESPACES_DIR]';\n";
        }

        echo "CREATE TABLESPACE I2B2;\n";

    } elseif($command == "drop") {
        echo "DROP TABLESPACE I2B2 INCLUDING CONTENTS AND DATAFILES CASCADE CONSTRAINTS;\n";
    }
}
