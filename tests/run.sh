#!/bin/sh

echo "Running tests"

rm -rf /code/tests/data

# TEST 1

cp -r /code/tests/data-source /code/tests/data

export KBC_PARAMETER_DIRECTION=tables
/code/run.sh

export EXPECTED="/code/tests/data/out/tables:
1
2.something
folder

/code/tests/data/out/tables/folder:
1
2.something"

if [ "$(ls -1R $KBC_DATADIR/out/tables)" != "$EXPECTED" ]; then
    echo "moved files to tables are different (1)"
    exit 1
fi

rm -rf /code/tests/data

# TEST 2

cp -r /code/tests/data-source /code/tests/data

export KBC_PARAMETER_ADDCSVSUFFIX="true"
/code/run.sh

export EXPECTED="/code/tests/data/out/tables:
1.csv
2.something.csv
folder.csv

/code/tests/data/out/tables/folder.csv:
1
2.something"

if [ "$(ls -1R $KBC_DATADIR/out/tables)" != "$EXPECTED" ]; then
    echo "moved files to tables are different (2)"
    exit 1
fi

rm -rf /code/tests/data

# TEST 3

cp -r /code/tests/data-source /code/tests/data

export KBC_PARAMETER_ADDCSVSUFFIX="1"
/code/run.sh

export EXPECTED="/code/tests/data/out/tables:
1.csv
2.something.csv
folder.csv

/code/tests/data/out/tables/folder.csv:
1
2.something"

if [ "$(ls -1R $KBC_DATADIR/out/tables)" != "$EXPECTED" ]; then
    echo "moved files to tables are different (3)"
    exit 1
fi

rm -rf /code/tests/data

# TEST 4

mkdir /code/tests/data
mkdir /code/tests/data/in
mkdir /code/tests/data/in/tables
mkdir /code/tests/data/in/files
mkdir /code/tests/data/out
mkdir /code/tests/data/out/tables
mkdir /code/tests/data/out/files

export KBC_PARAMETER_DIRECTION=tables
/code/run.sh

if [ "$(ls -1R $KBC_DATADIR/out/tables)" != "/code/tests/data/out/tables:" ]; then
    echo "moved empty files to tables are different (4)"
    exit 1
fi

rm -rf /code/tests/data

# TEST 5

cp -r /code/tests/data-source /code/tests/data

export KBC_PARAMETER_DIRECTION=files
/code/run.sh

export EXPECTED="/code/tests/data/out/files:
1.csv
2.csv
sliced

/code/tests/data/out/files/sliced:
1.csv
2.csv"

if [ "$(ls -1R $KBC_DATADIR/out/files)" != "$EXPECTED" ]; then
    echo "moved files to tables are different (1)"
    exit 1
fi

rm -rf /code/tests/data

# TEST 6

mkdir /code/tests/data
mkdir /code/tests/data/in
mkdir /code/tests/data/in/tables
mkdir /code/tests/data/in/files
mkdir /code/tests/data/out
mkdir /code/tests/data/out/tables
mkdir /code/tests/data/out/files

export KBC_PARAMETER_DIRECTION=files
/code/run.sh

if [ "$(ls -1R $KBC_DATADIR/out/files)" != "/code/tests/data/out/files:" ]; then
    echo "moved files to tables are different (2)"
    exit 1
fi

rm -rf /code/tests/data

echo "Tests finished"
