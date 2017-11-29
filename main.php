<?php
// Catch all warnings and notices
set_error_handler(function ($errno, $errstr, $errfile, $errline, array $errcontext) {
    throw new ErrorException($errstr, 0, $errno, $errfile, $errline);
});
require __DIR__ . "/vendor/autoload.php";

use Symfony\Component\Serializer\Encoder\JsonDecode;
use Symfony\Component\Serializer\Encoder\JsonEncoder;

$arguments = getopt("", ["data:"]);
if (!isset($arguments["data"])) {
    $dataFolder = "/data";
} else {
    $dataFolder = $arguments["data"];
}

$configFile = $dataFolder . "/config.json";
if (!file_exists($configFile)) {
    echo "Config file not found" . "\n";
    exit(2);
}

try {
    $jsonDecode = new JsonDecode(true);
    $jsonEncode = new \Symfony\Component\Serializer\Encoder\JsonEncode();

    $config = $jsonDecode->decode(
        file_get_contents($dataFolder . "/config.json"),
        JsonEncoder::FORMAT
    );
    $parameters = (new \Symfony\Component\Config\Definition\Processor())->processConfiguration(
        new \Keboola\Processor\MoveFiles\ConfigDefinition(),
        [isset($config["parameters"]) ? $config["parameters"] : []]
    );

    $renameSuffix = "";
    if ($parameters["direction"] === "files") {
        $sourcePath = $dataFolder . "/in/tables";
        $outputPath = $dataFolder . "/out/files/";
    }

    if ($parameters["direction"] === "tables") {
        $sourcePath = $dataFolder . "/in/files";
        $outputPath = $dataFolder . "/out/tables/";

        if ($parameters["addCsvSuffix"] === true) {
            $renameSuffix = ".csv";
        }
    }

    $fs = new \Symfony\Component\Filesystem\Filesystem();

    // move folders
    $finder = new \Symfony\Component\Finder\Finder();
    $finder->directories()->notName("*.manifest")->in($sourcePath)->depth(0);
    foreach ($finder as $sourceDirectory) {
        $fs->rename($sourceDirectory->getPathname(), $outputPath . "/" . $sourceDirectory->getBasename() . $renameSuffix);
    }

    // move files
    $finder = new \Symfony\Component\Finder\Finder();
    $finder->files()->notName("*.manifest")->in($sourcePath)->depth(0);
    foreach ($finder as $sourceFile) {
        $fs->rename($sourceFile->getPathname(), $outputPath . "/" . $sourceFile->getBasename() . $renameSuffix);
    }
} catch (\Symfony\Component\Config\Definition\Exception\InvalidConfigurationException $e) {
    echo "Invalid configuration: " . $e->getMessage();
    exit(1);
} catch (\Keboola\Processor\MoveFiles\Exception $e) {
    echo $e->getMessage();
    exit(1);
}
