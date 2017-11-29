# processor-move-files

[![Build Status](https://travis-ci.org/keboola/processor-move-files.svg?branch=master)](https://travis-ci.org/keboola/processor-move-files)

Move files processor. Moves files (or folders with sliced tables)

 - from `/in/tables/*` to `/out/files/*` or
 - from `/in/files/*` to `/out/tables/*.csv` (optionally adds `.csv` suffix to each file)
  
Does not copy manifest files.
 
# Development
 
Clone this repository and init the workspace with following commands:

```
git clone https://github.com/keboola/processor-move-files
cd processor-move-files
docker-compose build

```

Run the test suite using this command:

```
docker-compose run --rm dev php /code/tests/run.php
```
 
# Integration
 - Build is started after push on [Travis CI](https://travis-ci.org/keboola/processor-move-files)
 - [Build steps](https://github.com/keboola/processor-move-files/blob/master/.travis.yml)
   - build image
   - execute tests against new image
   - publish image to AWS ECR if the release is tagged
   
# Usage

## Sample configuration

```
{  
    "definition": {
        "component": "keboola.processor-move-files"
    },
    "parameters": {
        "direction": "tables",
        "addCsvSuffix": true
    }
}
```

## Parameters

### direction

 - **tables**: from `/in/files/*` to `/out/tables/*` 
 - **files**: from `/in/tables/*` to `/out/files/*`

### addCsvSuffix

Available only on `tables` direction, adds `.csv` suffix to each file.
