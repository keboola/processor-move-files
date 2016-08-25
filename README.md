# processor-move-files

[![Build Status](https://travis-ci.org/keboola/processor-move-files.svg?branch=master)](https://travis-ci.org/keboola/processor-move-files)
[![Docker Repository on Quay](https://quay.io/repository/keboola/processor-move-files/status "Docker Repository on Quay")](https://quay.io/repository/keboola/processor-move-files)

Move files processor. Moves files

 - from `/in/tables/*` to `/out/files/*` or
 - from `/in/files/*` to `/out/tables/*.csv` (adds `.csv` suffix to each file)
  
Does not copy manifest files.
 
## Development
 
Clone this repository and init the workspace with following commands:

- `docker-compose build`

### TDD 

 - Edit the code
 - Run `docker-compose run --rm --entrypoint sh -e KBC_DATADIR=/code/tests/data processor-move-files /code/tests/run.sh` 
 - Repeat
 
# Integration
 - Build is started after push on [Travis CI](https://travis-ci.org/keboola/processor-move-files)
 - [Build steps](https://github.com/keboola/processor-move-files/blob/master/.travis.yml)
   - build image
   - execute tests against new image
   - publish image to [quay.io](https://quay.io/repository/keboola/processor-move-files). Only if release is tagged
   
# Usage

## Sample configuration

```
{  
    "definition": {
        "component": "keboola.processor.move-files"
    },
    "parameters": {
        "direction": "tables" 
    }
}
```

## Parameters

### direction

 - **tables**: from `/in/files/*` to `/out/tables/*.csv` (adds `.csv` suffix to each file)
 - **files**: from `/in/tables/*` to `/out/files/*`