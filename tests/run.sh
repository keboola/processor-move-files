#!/bin/sh

echo "Running tests"

rm -rf /code/tests/data
cp -r /code/tests/data-source /code/tests/data

export KBC_PARAMETER_DIRECTION=tables
/code/run.sh
if [ "$(ls -C $KBC_DATADIR/out/tables)" != "1            2.something" ]; then
    echo "moved files to tables are different (1)"
    exit 1
fi

rm -rf /code/tests/data
cp -r /code/tests/data-source /code/tests/data

export KBC_PARAMETER_ADDCSVSUFFIX="true"
/code/run.sh
if [ "$(ls -C $KBC_DATADIR/out/tables)" != "1.csv            2.something.csv" ]; then
    echo "moved files to tables are different (2)"
    exit 1
fi

rm -rf /code/tests/data
cp -r /code/tests/data-source /code/tests/data

export KBC_PARAMETER_ADDCSVSUFFIX="1"
/code/run.sh
if [ "$(ls -C $KBC_DATADIR/out/tables)" != "1.csv            2.something.csv" ]; then
    echo "moved files to tables are different (3)"
    exit 1
fi

rm -rf /code/tests/data
mkdir /code/tests/data
mkdir /code/tests/data/in
mkdir /code/tests/data/in/tables
mkdir /code/tests/data/in/files
mkdir /code/tests/data/out
mkdir /code/tests/data/out/tables
mkdir /code/tests/data/out/files

export KBC_PARAMETER_DIRECTION=tables
/code/run.sh
if [ "$(ls -C $KBC_DATADIR/out/tables)" != "" ]; then
    echo "moved empty files to tables are different (4)"
    exit 1
fi

rm -rf /code/tests/data
cp -r /code/tests/data-source /code/tests/data

export KBC_PARAMETER_DIRECTION=files
/code/run.sh
if [ "$(ls -C $KBC_DATADIR/out/files)" != "1.csv  2.csv" ]; then
    echo "moved files to tables are different (1)"
    exit 1
fi

rm -rf /code/tests/data
mkdir /code/tests/data
mkdir /code/tests/data/in
mkdir /code/tests/data/in/tables
mkdir /code/tests/data/in/files
mkdir /code/tests/data/out
mkdir /code/tests/data/out/tables
mkdir /code/tests/data/out/files

export KBC_PARAMETER_DIRECTION=files
/code/run.sh
if [ "$(ls -C $KBC_DATADIR/out/files)" != "" ]; then
    echo "moved files to tables are different (2)"
    exit 1
fi

rm -rf /code/tests/data

echo "Tests finished"
