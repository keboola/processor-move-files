#!/bin/sh
if [ $KBC_PARAMETER_DIRECTION == "files" ]; then
    cd $KBC_DATADIR/in/tables/
    find . ! -iname "*.manifest" ! -name "." | xargs -n1 -I {} sh -c "cp \"{}\" $KBC_DATADIR/out/files/\"{}\""
fi

if [ $KBC_PARAMETER_DIRECTION == "tables" ]; then
    cd $KBC_DATADIR/in/files/
    find . ! -iname "*.manifest" ! -name "." | xargs -n1 -I {} sh -c "cp \"{}\" $KBC_DATADIR/out/tables/\"{}\".csv"
fi


