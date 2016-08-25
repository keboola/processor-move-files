#!/bin/sh

echo "Running tests"

export KBC_PARAMETER_DIRECTION=tables
/code/run.sh
if [ "$(ls -C $KBC_DATADIR/out/tables)" != "1.csv            2.something.csv" ]; then
    echo "moved files to tables are different"
    exit 1
fi

export KBC_PARAMETER_DIRECTION=files
/code/run.sh
if [ "$(ls -C $KBC_DATADIR/out/files)" != "1.csv  2.csv" ]; then
    echo "moved files to files are different"
    exit 1
fi

echo "Tests finished"
