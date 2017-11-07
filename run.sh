#!/bin/sh
if [ $KBC_PARAMETER_DIRECTION == "files" ]; then
    cd $KBC_DATADIR/in/tables/
    # move folders
    find . ! -iname "*.manifest" ! -name "." -type d | xargs -n1 -I {} sh -c "mv \"{}\" $KBC_DATADIR/out/files/\"{}\""
    # move files
    find . ! -iname "*.manifest" ! -name "." | xargs -n1 -I {} sh -c "mv \"{}\" $KBC_DATADIR/out/files/\"{}\""
fi

if [ $KBC_PARAMETER_DIRECTION == "tables" ]; then
    [ -z "$KBC_PARAMETER_ADDCSVSUFFIX" ] && export KBC_PARAMETER_ADDCSVSUFFIX=0;
    cd $KBC_DATADIR/in/files/
    if [ $KBC_PARAMETER_ADDCSVSUFFIX == "true" ] || [ $KBC_PARAMETER_ADDCSVSUFFIX == "1" ]; then
        # move folders
        find . ! -iname "*.manifest" ! -name "." -type d | xargs -n1 -I {} sh -c "mv \"{}\" $KBC_DATADIR/out/tables/\"{}\".csv"
        # move files
        find . ! -iname "*.manifest" ! -name "." | xargs -n1 -I {} sh -c "mv \"{}\" $KBC_DATADIR/out/tables/\"{}\".csv"
        exit 0
    else
        # move folders
        find . ! -iname "*.manifest" ! -name "." -type d | xargs -n1 -I {} sh -c "mv \"{}\" $KBC_DATADIR/out/tables/\"{}\""
        # move files
        find . ! -iname "*.manifest" ! -name "." | xargs -n1 -I {} sh -c "mv \"{}\" $KBC_DATADIR/out/tables/\"{}\""
    fi
fi


