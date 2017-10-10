#!/bin/sh
if [ $KBC_PARAMETER_DIRECTION == "files" ]; then
    cd $KBC_DATADIR/in/tables/
    find . ! -iname "*.manifest" ! -name "." | xargs -n1 -I {} sh -c "mv \"{}\" $KBC_DATADIR/out/files/\"{}\""
fi

if [ $KBC_PARAMETER_DIRECTION == "tables" ]; then
    [ -z "$KBC_PARAMETER_ADDCSVSUFFIX" ] && export KBC_PARAMETER_ADDCSVSUFFIX=0;
    cd $KBC_DATADIR/in/files/
    if [ $KBC_PARAMETER_ADDCSVSUFFIX == "true" ] || [ $KBC_PARAMETER_ADDCSVSUFFIX == "1" ]; then
        find . ! -iname "*.manifest" ! -name "." | xargs -n1 -I {} sh -c "mv \"{}\" $KBC_DATADIR/out/tables/\"{}\".csv"
        exit 0
    else
        find . ! -iname "*.manifest" ! -name "." | xargs -n1 -I {} sh -c "mv \"{}\" $KBC_DATADIR/out/tables/\"{}\""
    fi
fi


