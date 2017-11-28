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

    $fs = new \Symfony\Component\Filesystem\Filesystem();

    if ($parameters["direction"] === "files") {
        $outputPath = $dataFolder . "/out/files/";

        $finder = new \Symfony\Component\Finder\Finder();
        $finder->directories()->notName("*.manifest")->in($dataFolder . "/in/tables")->depth(0);
        foreach ($finder as $sourceDirectory) {
            $moveCommand = "mv " . $sourceDirectory->getPathName() . " " . $outputPath . "/" . $sourceDirectory->getBasename();
            (new \Symfony\Component\Process\Process($moveCommand))->mustRun();
        }

        $finder = new \Symfony\Component\Finder\Finder();
        $finder->notName("*.manifest")->in($dataFolder . "/in/tables")->depth(0);
        foreach ($finder as $sourceFile) {
            $moveCommand = "mv " . $sourceFile->getPathName() . " " . $outputPath . "/" . $sourceFile->getBasename();
            (new \Symfony\Component\Process\Process($moveCommand))->mustRun();
        }
    }

    if ($parameters["direction"] === "tables") {
        $outputPath = $dataFolder . "/out/tables/";

        $csvSuffix = "";
        if ($parameters["addCsvSuffix"] === true) {
            $csvSuffix = ".csv";
        }

        $finder = new \Symfony\Component\Finder\Finder();
        $finder->directories()->notName("*.manifest")->in($dataFolder . "/in/files")->depth(0);
        foreach ($finder as $sourceDirectory) {
            $moveCommand = "mv " . $sourceDirectory->getPathName() . " " . $outputPath . "/" . $sourceDirectory->getBasename() . $csvSuffix;
            (new \Symfony\Component\Process\Process($moveCommand))->mustRun();
        }

        $finder = new \Symfony\Component\Finder\Finder();
        $finder->files()->notName("*.manifest")->in($dataFolder . "/in/files")->depth(0);
        foreach ($finder as $sourceFile) {
            $moveCommand = "mv " . $sourceFile->getPathName() . " " . $outputPath . "/" . $sourceFile->getBasename() . $csvSuffix;
            (new \Symfony\Component\Process\Process($moveCommand))->mustRun();
        }
    }
} catch (\Symfony\Component\Config\Definition\Exception\InvalidConfigurationException $e) {
    echo "Invalid configuration: " . $e->getMessage();
    exit(1);
} catch (\Keboola\Processor\MoveFiles\Exception $e) {
    echo $e->getMessage();
    exit(1);
}
