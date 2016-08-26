#!/bin/sh

echo "Running tests"

rm -f $KBC_DATADIR/out/tables/1.csv
rm -f $KBC_DATADIR/out/tables/1
rm -f $KBC_DATADIR/out/tables/2.something
rm -f $KBC_DATADIR/out/tables/2.something.csv

rm -f $KBC_DATADIR/out/files/1.csv
rm -f $KBC_DATADIR/out/files/2.csv

export KBC_PARAMETER_DIRECTION=tables
/code/run.sh
if [ "$(ls -C $KBC_DATADIR/out/tables)" != "1            2.something" ]; then
    echo "moved files to tables are different (1)"
    exit 1
fi

rm -f $KBC_DATADIR/out/tables/1.csv
rm -f $KBC_DATADIR/out/tables/1
rm -f $KBC_DATADIR/out/tables/2.something
rm -f $KBC_DATADIR/out/tables/2.something.csv

export KBC_PARAMETER_ADDCSVSUFFIX="true"
/code/run.sh
if [ "$(ls -C $KBC_DATADIR/out/tables)" != "1.csv            2.something.csv" ]; then
    echo "moved files to tables are different (2)"
    exit 1
fi

rm -f $KBC_DATADIR/out/tables/1.csv
rm -f $KBC_DATADIR/out/tables/1
rm -f $KBC_DATADIR/out/tables/2.something
rm -f $KBC_DATADIR/out/tables/2.something.csv

export KBC_PARAMETER_ADDCSVSUFFIX="1"
/code/run.sh
if [ "$(ls -C $KBC_DATADIR/out/tables)" != "1.csv            2.something.csv" ]; then
    echo "moved files to tables are different (3)"
    exit 1
fi

rm -f $KBC_DATADIR/out/tables/1.csv
rm -f $KBC_DATADIR/out/tables/1
rm -f $KBC_DATADIR/out/tables/2.something
rm -f $KBC_DATADIR/out/tables/2.something.csv

export KBC_PARAMETER_DIRECTION=files
/code/run.sh
if [ "$(ls -C $KBC_DATADIR/out/files)" != "1.csv  2.csv" ]; then
    echo "moved files to files are different"
    exit 1
fi

rm -f $KBC_DATADIR/out/files/1.csv
rm -f $KBC_DATADIR/out/files/2.csv

echo "Tests finished"
