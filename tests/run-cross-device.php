<?php

declare(strict_types=1);

use Keboola\Temp\Temp;
use Symfony\Component\Filesystem\Filesystem;
use Symfony\Component\Process\Process;

require_once(__DIR__ . '/../vendor/autoload.php');

// Reuses the fixture of the regular suite - the same scenario, only staged across a device boundary.
$fixturePath = __DIR__ . '/tables-slices';

/**
 * The regular suite stages the whole data dir in one directory, so rename(2) never crosses a device there.
 * Under the no-dind job executor /data/in and /data/out are separate mounts and rename(2) returns EXDEV.
 * tmpfs at /dev/shm reproduces that boundary without the CAP_SYS_ADMIN a bind mount would need.
 */
$deviceOf = function (string $path): int {
    $stat = stat($path);
    if ($stat === false) {
        print "Failed to stat {$path}\n";
        exit(1);
    }

    return (int) $stat['dev'];
};

$printProcessOutput = function (Process $process): void {
    if ($process->getOutput()) {
        print "\n" . $process->getOutput() . "\n";
    }
    if ($process->getErrorOutput()) {
        print "\n" . $process->getErrorOutput() . "\n";
    }
};

print 'Test ' . $fixturePath . " (cross-device)\n";

$fs = new Filesystem();
$temp = new Temp('processor-move-files-cross-device');
$temp->initRunFolder();
$dataDir = $temp->getTmpFolder();
$tmpfsInPath = '/dev/shm/' . basename($dataDir) . '-in';

try {
    $fs->mkdir([$dataDir . '/out/tables', $dataDir . '/out/files']);
    $fs->copy($fixturePath . '/source/data/config.json', $dataDir . '/config.json');

    $copyCommand = 'cp -R ' . escapeshellarg($fixturePath . '/source/data/in') . ' ' . escapeshellarg($tmpfsInPath);
    (new Process($copyCommand))->mustRun();
    $fs->symlink($tmpfsInPath, $dataDir . '/in');

    $inDevice = $deviceOf($dataDir . '/in/files');
    $outDevice = $deviceOf($dataDir . '/out/tables');
    if ($inDevice === $outDevice) {
        print "in/ and out/ both ended up on device {$inDevice}.\n";
        print "Without a device boundary rename(2) succeeds and this test passes without testing anything.\n";
        exit(1);
    }

    $runProcess = new Process('php /code/main.php --data=' . escapeshellarg($dataDir));
    $runProcess->run();

    if ($runProcess->getExitCode() !== 0) {
        print "Unexpectedly failed with exit code {$runProcess->getExitCode()}.\n";
        $printProcessOutput($runProcess);
        exit(1);
    }

    $diffCommand = 'diff --exclude=.gitkeep --ignore-all-space --recursive ';
    $diffCommand .= escapeshellarg($fixturePath . '/expected/data/out') . ' ';
    $diffCommand .= escapeshellarg($dataDir . '/out');
    $diffProcess = new Process($diffCommand);
    $diffProcess->run();
    if ($diffProcess->getExitCode() !== 0) {
        $printProcessOutput($diffProcess);
        exit(1);
    }

    // a copy that forgets to unlink the origin still passes the diff above
    if ($fs->exists($tmpfsInPath . '/files/slices')) {
        print "The moved directory was left behind in {$tmpfsInPath}/files.\n";
        exit(1);
    }
} finally {
    $fs->remove($tmpfsInPath);
}
