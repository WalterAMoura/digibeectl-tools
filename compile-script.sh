#!/bin/bash

SCRIPT=$1

if [ -z $SCRIPT ]; then
    echo "Erro ao executar compilação."
else
    shc -f $SCRIPT.sh
    mv -vf "$SCRIPT.sh.x.c" ".$SCRIPT.sh.x.c"
    mv -vf "$SCRIPT.sh.x" "$SCRIPT"
fi