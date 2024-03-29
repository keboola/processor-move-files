<?php

declare(strict_types=1);

// Catch all warnings and notices
set_error_handler(function ($errno, $errstr, $errfile, $errline, array $errcontext): ErrorException {
    throw new ErrorException($errstr, 0, $errno, $errfile, $errline);
});
require __DIR__ . '/vendor/autoload.php';

use Keboola\Processor\MoveFiles\ConfigDefinition;
use Keboola\Processor\MoveFiles\Exception;
use Symfony\Component\Config\Definition\Exception\InvalidConfigurationException;
use Symfony\Component\Config\Definition\Processor;
use Symfony\Component\Filesystem\Filesystem;
use Symfony\Component\Finder\Finder;
use Symfony\Component\Serializer\Encoder\JsonDecode;
use Symfony\Component\Serializer\Encoder\JsonEncode;
use Symfony\Component\Serializer\Encoder\JsonEncoder;

$arguments = getopt('', ['data:']);
if (!isset($arguments['data'])) {
    $dataFolder = '/data';
} else {
    $dataFolder = $arguments['data'];
}

$configFile = $dataFolder . '/config.json';
if (!file_exists($configFile)) {
    echo 'Config file not found' . "\n";
    exit(2);
}

try {
    $jsonDecode = new JsonDecode(true);
    $jsonEncode = new JsonEncode();

    $config = $jsonDecode->decode(
        file_get_contents($dataFolder . '/config.json'),
        JsonEncoder::FORMAT
    );
    $parameters = (new Processor())->processConfiguration(
        new ConfigDefinition(),
        [isset($config['parameters']) ? $config['parameters'] : []]
    );

    $renameSuffix = '';
    if ($parameters['direction'] === 'files') {
        $sourcePath = $dataFolder . '/in/tables';
        $outputPath = $dataFolder . '/out/files/';
    } else {
        $sourcePath = $dataFolder . '/in/files';
        $outputPath = $dataFolder . '/out/tables/';

        if ($parameters['addCsvSuffix'] === true) {
            $renameSuffix = '.csv';
        }
    }

    $fs = new Filesystem();

    if ($parameters['folder'] !== '') {
        $outputPath .= $parameters['folder'] . '/';
        if ($parameters['createEmptyFolder'] === true) {
            $fs->mkdir($outputPath);
        }
    }

    // move folders
    $finder = new Finder();
    $finder->directories()->notName('*.manifest')->in($sourcePath)->depth(0);
    foreach ($finder as $sourceDirectory) {
        $fs->mkdir($outputPath);
        $fs->rename(
            $sourceDirectory->getPathname(),
            $outputPath . '/' . $sourceDirectory->getBasename() . $renameSuffix
        );
    }

    // move files
    $finder = new Finder();
    $finder->files()->notName('*.manifest')->in($sourcePath)->depth(0);
    foreach ($finder as $sourceFile) {
        $fs->mkdir($outputPath);
        $fs->rename($sourceFile->getPathname(), $outputPath . '/' . $sourceFile->getBasename() . $renameSuffix);
    }
} catch (InvalidConfigurationException $e) {
    echo 'Invalid configuration: ' . $e->getMessage();
    exit(1);
} catch (Exception $e) {
    echo $e->getMessage();
    exit(1);
}
