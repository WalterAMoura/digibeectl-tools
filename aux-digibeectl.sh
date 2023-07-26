#!/bin/bash
#
# Autor: Walter Moura
# Data Criacao: 01/08/2022
# Data Modificacao: 
#
# Script usado para interagir com digibeectl de forma mais controlada

# Definições de variaveis 'globais'

# Dados de usuário
USERACTUAL=$(grep $EUID /etc/group | awk -F ":" '{print $1}')
PATH_USER="/home/$USERACTUAL/Documentos/digibeectl"
PATH_BKP="$PATH_USER/backup"
PATH_LOG="$PATH_USER/log"

# Dados de configuração
CONFIG="$PATH_USER/config.conf"
SCRIPT=`basename $0`

# Logs
DEBUG="$PATH_LOG/debug_$(echo $SCRIPT | cut -d '.' -f1).log"
LOG="$PATH_LOG/$(echo $SCRIPT | cut -d '.' -f1).log"

# Arquivos de input e output
OUTPUT_FILE_LIST_PIPELINES="$PATH_USER/.listPipelines.txt"
TEMP_OUTPUT_FILE_LIST_PIPELINES="$PATH_USER/.tempListPipelines.txt"
OUTPUT_FILE_FULL_LIST_PIPELINES="$PATH_USER/.listFullPipelines.txt"
TEMP_OUTPUT_FULL_FILE_LIST_PIPELINES="$PATH_USER/.tempListFullPipelines.txt"
OUTPUT_FILE_LIST_DEPLOYMENT_PIPELINES="$PATH_USER/.listDeploymentPipelines.txt"
TEMP_OUTPUT_FILE_LIST_DEPLOYMENT_PIPELINES="$PATH_USER/.tempListDeploymentPipelines.txt"
INPUT_FILE_MULT_GLOBALS="$PATH_USER/globals.txt"
INPUT_FILE_MULT_CAPSULES="$PATH_USER/capsules.txt"
INPUT_FILE_MULT_ACCOUNTS="$PATH_USER/accounts.txt"
INPUT_FILE_MULT_DEPLOYS="$PATH_USER/pipelines-deploys.csv"
OUTPUT_PIPELINES_DEPLOYS="$PATH_USER/.pipelinesDeploys.txt"
INPUT_FILE_DELETE_DEPLOYS="$PATH_USER/pipelines-del-deploys.csv"
TEMP_OUTPUT_FIND="$PATH_USER/.tempOutpuFind.txt"
# Utilidades
PERC="|/-\|-"
PIPELINE_NAME=""
PIPELINE_VERSION_MAJOR=1
BYPASS_LIST_PIPELINES=0
TOTAL_LIST_PIPELINES=0

set -x
exec 2> $DEBUG

# Carrega configs
. $CONFIG

function list_pipelines(){
    echo "$(date +%Y%m%d-%H%M%S.%s):LIST_PIPELINES:" >> $LOG
    echo "$(date +%Y%m%d-%H%M%S.%s):LIST_PIPELINES:Iniciando função." >> $LOG
    
    echo "$(date +%Y%m%d-%H%M%S.%s):LIST_PIPELINES:Verificando se existi o arquivo: $OUTPUT_FILE_LIST_PIPELINES." >> $LOG
    if [ -e $OUTPUT_FILE_LIST_PIPELINES ]; then
        echo "$(date +%Y%m%d-%H%M%S.%s):LIST_PIPELINES:Excluindo arquivo." >> $LOG
        rm $OUTPUT_FILE_LIST_PIPELINES
        RET=$?
        if [ $RET -eq 0 ]; then
            echo "$(date +%Y%m%d-%H%M%S.%s):LIST_PIPELINES:Arquivo excluido com sucesso." >> $LOG 
        else
            echo "$(date +%Y%m%d-%H%M%S.%s):LIST_PIPELINES:Error ao excluir arquivo." >> $LOG
        fi
    fi
    echo "$(date +%Y%m%d-%H%M%S.%s):LIST_PIPELINES:Verificando se existi o arquivo: $TEMP_OUTPUT_FILE_LIST_PIPELINES." >> $LOG
    if [ -e $TEMP_OUTPUT_FILE_LIST_PIPELINES ]; then
        echo "$(date +%Y%m%d-%H%M%S.%s):LIST_PIPELINES:Excluindo arquivo." >> $LOG
        rm $TEMP_OUTPUT_FILE_LIST_PIPELINES
        RET=$?
        if [ $RET -eq 0 ]; then
            echo "$(date +%Y%m%d-%H%M%S.%s):LIST_PIPELINES:Arquivo excluido com sucesso." >> $LOG 
        else
            echo "$(date +%Y%m%d-%H%M%S.%s):LIST_PIPELINES:Error ao excluir arquivo." >> $LOG
        fi
    fi

    echo "$(date +%Y%m%d-%H%M%S.%s):LIST_PIPELINES:GET dados de paginação." >> $LOG
    currentPage=`digibeectl get pipelines | grep page | cut -d "-" -f2 | sed -e 's/of/-/g' | sed -e 's/page//g' | cut -d '-' -f 1`
    totalPages=`digibeectl get pipelines | grep page | cut -d "-" -f2 | sed -e 's/of/-/g' | sed -e 's/page//g' | cut -d '-' -f 2`

    if [ -z $currentPage ]; then
        currentPage=1
    fi

    if [ -z $totalPages ]; then
        totalPages=1
    fi

    totalPages=`printf '%d' $totalPages`
    currentPage=`printf '%d' $currentPage`

    echo "$(date +%Y%m%d-%H%M%S.%s):LIST_PIPELINES:Dados de paginação - totalPages: $totalPages | currentPage: $currentPage." >> $LOG

    printf '\n'

    x=0

    echo "$(date +%Y%m%d-%H%M%S.%s):LIST_PIPELINES:Iniciando o loop para percorrer as paginas." >> $LOG
    while true; do
        if [ $x -lt $totalPages ]; then
            echo -e "\033[01;33m[ CONSULTANDO PAGINAS - $(($x+1)) de $totalPages ]\033[00;37m"
            echo "$(date +%Y%m%d-%H%M%S.%s):LIST_PIPELINES:[ CONSULTANDO PAGINAS - $(($x+1)) de $totalPages ]." >> $LOG
            if [ $x -eq  0 ]; then
                digibeectl get pipelines --page $(($x+1)) > $TEMP_OUTPUT_FILE_LIST_PIPELINES
                n=`cat $TEMP_OUTPUT_FILE_LIST_PIPELINES | wc -l`
                cat $TEMP_OUTPUT_FILE_LIST_PIPELINES | grep PIPELINE-ID -A$(($n-2)) | sed '1d' > $OUTPUT_FILE_LIST_PIPELINES
            else
                digibeectl get pipelines --page $(($x+1)) > $TEMP_OUTPUT_FILE_LIST_PIPELINES
                n=`cat $TEMP_OUTPUT_FILE_LIST_PIPELINES | wc -l`
                cat $TEMP_OUTPUT_FILE_LIST_PIPELINES | grep PIPELINE-ID -A$(($n-2)) | sed '1d' >> $OUTPUT_FILE_LIST_PIPELINES
            fi
        else
            break
        fi
        #let "TOTAL_LIST_PIPELINES = TOTAL_LIST_PIPELINES +1"
        let "x = x +1"
    done
    #remove linhas em branco
    grep -v '^[\s\t]*$' $OUTPUT_FILE_LIST_PIPELINES > $TEMP_OUTPUT_FILE_LIST_PIPELINES
    cp $TEMP_OUTPUT_FILE_LIST_PIPELINES $OUTPUT_FILE_LIST_PIPELINES
    TOTAL_LIST_PIPELINES=`cat $OUTPUT_FILE_LIST_PIPELINES | wc -l`

    echo "$(date +%Y%m%d-%H%M%S.%s):LIST_PIPELINES: $TOTAL_LIST_PIPELINES" >> $LOG
    echo "$(date +%Y%m%d-%H%M%S.%s):LIST_PIPELINES:Função finalizada." >> $LOG
}

function full_list_pipeline(){
    echo "$(date +%Y%m%d-%H%M%S.%s):FULL_LIST_PIPELINES:" >> $LOG
    echo "$(date +%Y%m%d-%H%M%S.%s):FULL_LIST_PIPELINES:Iniciando função." >> $LOG
    
    echo "$(date +%Y%m%d-%H%M%S.%s):FULL_LIST_PIPELINES:Verificando se existi o arquivo: $OUTPUT_FILE_FULL_LIST_PIPELINES." >> $LOG
    if [ -e $OUTPUT_FILE_FULL_LIST_PIPELINES ]; then
        echo "$(date +%Y%m%d-%H%M%S.%s):FULL_LIST_PIPELINES:Excluindo arquivo." >> $LOG
        rm $OUTPUT_FILE_FULL_LIST_PIPELINES
        RET=$?
        if [ $RET -eq 0 ]; then
            echo "$(date +%Y%m%d-%H%M%S.%s):FULL_LIST_PIPELINES:Arquivo excluido com sucesso." >> $LOG 
        else
            echo "$(date +%Y%m%d-%H%M%S.%s):FULL_LIST_PIPELINES:Error ao excluir arquivo." >> $LOG
        fi
    fi
    echo "$(date +%Y%m%d-%H%M%S.%s):FULL_LIST_PIPELINES:Verificando se existi o arquivo: $TEMP_OUTPUT_FULL_FILE_LIST_PIPELINES." >> $LOG
    if [ -e $TEMP_OUTPUT_FULL_FILE_LIST_PIPELINES ]; then
        echo "$(date +%Y%m%d-%H%M%S.%s):FULL_LIST_PIPELINES:Excluindo arquivo." >> $LOG
        rm $TEMP_OUTPUT_FULL_FILE_LIST_PIPELINES
        RET=$?
        if [ $RET -eq 0 ]; then
            echo "$(date +%Y%m%d-%H%M%S.%s):FULL_LIST_PIPELINES:Arquivo excluido com sucesso." >> $LOG 
        else
            echo "$(date +%Y%m%d-%H%M%S.%s):FULL_LIST_PIPELINES:Error ao excluir arquivo." >> $LOG
        fi
    fi

    echo "$(date +%Y%m%d-%H%M%S.%s):LIST_PIPELINES:GET dados de paginação." >> $LOG
    #currentPage=`digibeectl get pipelines | grep page | cut -d "-" -f2 | sed -e 's/of/-/g' | sed -e 's/page//g' | cut -d '-' -f 1`
    totalPages=`digibeectl get pipelines | grep page | cut -d "-" -f2 | sed -e 's/of/-/g' | sed -e 's/page//g' | cut -d '-' -f 2`

    if [ -z $currentPage ]; then
        currentPage=1
    fi

    if [ -z $totalPages ]; then
        totalPages=1
    fi

    totalPages=`printf '%d' $totalPages`
    currentPage=`printf '%d' $currentPage`

    echo "$(date +%Y%m%d-%H%M%S.%s):FULL_LIST_PIPELINES:Dados de paginação - totalPages: $totalPages | currentPage: $currentPage." >> $LOG

    printf '\n'

    x=0
    echo "$(date +%Y%m%d-%H%M%S.%s):FULL_LIST_PIPELINES:Iniciando o loop para percorrer as paginas." >> $LOG
    while true; do
        if [ $x -lt $totalPages ]; then
            echo -e "\033[01;33m[ CONSULTANDO PAGINAS - $(($x+1)) de $totalPages ]\033[00;37m"
            echo "$(date +%Y%m%d-%H%M%S.%s):FULL_LIST_PIPELINES:[ CONSULTANDO PAGINAS - $(($x+1)) de $totalPages ]." >> $LOG
            if [ $x -eq  0 ]; then
                #digibeectl get pipelines --page $(($x+1)) > $TEMP_OUTPUT_FULL_FILE_LIST_PIPELINES
                digibeectl get pipeline --page $(($x+1)) --name "$PIPELINE_NAME" --pipeline-version-major $PIPELINE_VERSION_MAJOR --show-versions > $TEMP_OUTPUT_FULL_FILE_LIST_PIPELINES
                n=`cat $TEMP_OUTPUT_FULL_FILE_LIST_PIPELINES | wc -l`
                cat $TEMP_OUTPUT_FULL_FILE_LIST_PIPELINES | grep PIPELINE-ID -A$(($n-1)) | sed '1d' > $OUTPUT_FILE_FULL_LIST_PIPELINES
            else
                #digibeectl get pipelines --page $(($x+1)) > $TEMP_OUTPUT_FULL_FILE_LIST_PIPELINES
                digibeectl get pipeline --page $(($x+1)) --name "$PIPELINE_NAME" --pipeline-version-major $PIPELINE_VERSION_MAJOR --show-versions > $TEMP_OUTPUT_FULL_FILE_LIST_PIPELINES
                n=`cat $TEMP_OUTPUT_FULL_FILE_LIST_PIPELINES | wc -l`
                cat $TEMP_OUTPUT_FULL_FILE_LIST_PIPELINES | grep PIPELINE-ID -A$(($n-2)) | sed '1d' >> $OUTPUT_FILE_FULL_LIST_PIPELINES
            fi
        else
            break
        fi
        let "x = x +1"
    done

    #remove linhas em branco
    grep -v '^[\s\t]*$' $OUTPUT_FILE_FULL_LIST_PIPELINES > $TEMP_OUTPUT_FULL_FILE_LIST_PIPELINES
    cp $TEMP_OUTPUT_FULL_FILE_LIST_PIPELINES $OUTPUT_FILE_FULL_LIST_PIPELINES

    echo "$(date +%Y%m%d-%H%M%S.%s):FULL_LIST_PIPELINES:" >> $LOG
    echo "$(date +%Y%m%d-%H%M%S.%s):FULL_LIST_PIPELINES:Função finalizada." >> $LOG
}

function read_list_pipelines(){
    echo "$(date +%Y%m%d-%H%M%S.%s):READ_LIST_PIPELINES:" >> $LOG
    echo "$(date +%Y%m%d-%H%M%S.%s):READ_LIST_PIPELINES:Iniciando função." >> $LOG
    echo "$(date +%Y%m%d-%H%M%S.%s):READ_LIST_PIPELINES:Chamando a função -> list_pipelines()." >> $LOG
    list_pipelines
    printf '\n\n%s|%s|%s|%s\n' $(seq -s '-' 41 | tr -d [:digit:]) $(seq -s '-' 41 | tr -d [:digit:]) $(seq -s '-' 11 | tr -d [:digit:]) $(seq -s '-' 41 | tr -d [:digit:])
    printf '%-40s|%-40s|%-10s|%s\n' "NAME" "PIPELINE-ID" "VERSION" "ARCHIVED"
    printf '%s|%s|%s|%s\n' $(seq -s '-' 41 | tr -d [:digit:]) $(seq -s '-' 41 | tr -d [:digit:]) $(seq -s '-' 11 | tr -d [:digit:]) $(seq -s '-' 41 | tr -d [:digit:])
    IFS=" "
    echo "$(date +%Y%m%d-%H%M%S.%s):READ_LIST_PIPELINES:Exibir na tela lista de pipelines." >> $LOG
    while read name pipelineId version archived;
    do
        printf '%-40s|%-40s|%-10s|%s\n' $name $pipelineId $version $archived
        echo "$(date +%Y%m%d-%H%M%S.%s):READ_LIST_PIPELINES:$(printf '%s|%s|%s|%s' $name $pipelineId $version $archived)." >> $LOG
    done < $OUTPUT_FILE_LIST_PIPELINES

    printf '%s|%s|%s|%s\n' $(seq -s '-' 41 | tr -d [:digit:]) $(seq -s '-' 41 | tr -d [:digit:]) $(seq -s '-' 11 | tr -d [:digit:]) $(seq -s '-' 41 | tr -d [:digit:])

    echo "$(date +%Y%m%d-%H%M%S.%s):READ_LIST_PIPELINES:" >> $LOG
    echo "$(date +%Y%m%d-%H%M%S.%s):READ_LIST_PIPELINES:Função finalizada." >> $LOG
}

function find_text(){
    echo "$(date +%Y%m%d-%H%M%S.%s):FIND_TEXT:" >> $LOG
    echo "$(date +%Y%m%d-%H%M%S.%s):FIND_TEXT:Iniciando função." >> $LOG
    echo "$(date +%Y%m%d-%H%M%S.%s):FIND_TEXT:Verifica se precisa chamar a função list_pipelines()." >> $LOG
    # chama listagem de pipelines
    if [ $BYPASS_LIST_PIPELINES -eq 0 ]; then
        echo "$(date +%Y%m%d-%H%M%S.%s):FIND_GLOBAL:Chamando a função -> list_pipelines()." >> $LOG
        list_pipelines
    fi

    printf '%s|%s|%s|%s\n' $(seq -s '-' 41 | tr -d [:digit:]) $(seq -s '-' 41 | tr -d [:digit:]) $(seq -s '-' 11 | tr -d [:digit:]) $(seq -s '-' 41 | tr -d [:digit:])
    printf '%-40s|%-40s|%-10s|%s\n' "NAME" "PIPELINE-ID" "VERSION" "ARCHIVED"
    printf '%s|%s|%s|%s\n' $(seq -s '-' 41 | tr -d [:digit:]) $(seq -s '-' 41 | tr -d [:digit:]) $(seq -s '-' 11 | tr -d [:digit:]) $(seq -s '-' 41 | tr -d [:digit:])
    labelText=$labelText

    echo "$(date +%Y%m%d-%H%M%S.%s):FIND_TEXT:Global a ser buscada: $global." >> $LOG
    x=0
    while read name pipelineId version archived;
    do
        count=`digibeectl get pipelines --pipeline-id $pipelineId --flowspec | grep -a "$labelText" -o | wc -l`
        if [ $count -gt 0 ]; then 
            printf '%-40s|%-40s|%-10s|%s\n' $name $pipelineId $version $archived
            echo "$(date +%Y%m%d-%H%M%S.%s):FIND_TEXT:Pipeline encontrado: $(printf '%s|%s|%s|%s' $name $pipelineId $version $archived)." >> $LOG
            let "x = x +1"
        fi
        #printf '%-40s|%-40s|%-10s|%s\n' $name $pipelineId $version $archived
        #break
    done < $OUTPUT_FILE_LIST_PIPELINES
    printf '%s|%s\n' $(seq -s '-' 93 | tr -d [:digit:]) $(seq -s '-' 41 | tr -d [:digit:])
    printf '%-92s|%s\n' "TOTAL ENCONTRADO" "$x"
    printf '%s|%s\n' $(seq -s '-' 93 | tr -d [:digit:]) $(seq -s '-' 41 | tr -d [:digit:])

    echo "$(date +%Y%m%d-%H%M%S.%s):FIND_TEXT:Total encontrado: $x." >> $LOG
    echo "$(date +%Y%m%d-%H%M%S.%s):FIND_TEXT:" >> $LOG
    echo "$(date +%Y%m%d-%H%M%S.%s):FIND_TEXT:Função finalizada." >> $LOG
}

function find_global(){
    
    echo "$(date +%Y%m%d-%H%M%S.%s):FIND_GLOBAL:" >> $LOG
    echo "$(date +%Y%m%d-%H%M%S.%s):FIND_GLOBAL:Iniciando função." >> $LOG
    echo "$(date +%Y%m%d-%H%M%S.%s):FIND_GLOBAL:Verifica se precisa chamar a função list_pipelines()." >> $LOG
    # chama listagem de pipelines
    if [ $BYPASS_LIST_PIPELINES -eq 0 ]; then
        echo "$(date +%Y%m%d-%H%M%S.%s):FIND_GLOBAL:Chamando a função -> list_pipelines()." >> $LOG
        list_pipelines
    fi

    printf '%s|%s|%s|%s\n' $(seq -s '-' 41 | tr -d [:digit:]) $(seq -s '-' 41 | tr -d [:digit:]) $(seq -s '-' 11 | tr -d [:digit:]) $(seq -s '-' 41 | tr -d [:digit:]) > $TEMP_OUTPUT_FIND
    printf '%-40s|%-40s|%-10s|%s\n' "NAME" "PIPELINE-ID" "VERSION" "ARCHIVED" >> $TEMP_OUTPUT_FIND
    printf '%s|%s|%s|%s\n' $(seq -s '-' 41 | tr -d [:digit:]) $(seq -s '-' 41 | tr -d [:digit:]) $(seq -s '-' 11 | tr -d [:digit:]) $(seq -s '-' 41 | tr -d [:digit:]) >> $TEMP_OUTPUT_FIND
    global=$labelGlobal

    echo "$(date +%Y%m%d-%H%M%S.%s):FIND_GLOBAL:Global a ser buscada: $global." >> $LOG
    x=0
    i=0
    p=`echo "scale=2;100/$TOTAL_LIST_PIPELINES" | bc`
    printf '\n'
    while read name pipelineId version archived;
    do
        let "i = i +1"
        z=`echo "scale=2;$p*$i" | bc`
        printf '%s\n%s\n' "BUSCANDO GLOBAL: $labelGlobal" "LENDO PIPELINES: $z%"
        count=`digibeectl get pipelines --pipeline-id $pipelineId --flowspec | grep -a "$global" -o | wc -l`
        if [ $count -gt 0 ]; then 
            printf '%-40s|%-40s|%-10s|%s\n' $name $pipelineId $version $archived >> $TEMP_OUTPUT_FIND
            echo "$(date +%Y%m%d-%H%M%S.%s):FIND_GLOBAL:Pipeline encontrado: $(printf '%s|%s|%s|%s' $name $pipelineId $version $archived)." >> $LOG
            let "x = x +1"
        fi
        #printf '%-40s|%-40s|%-10s|%s\n' $name $pipelineId $version $archived
        #break
        clear
    done < $OUTPUT_FILE_LIST_PIPELINES

    clear
    printf '%s\n%s\n\n' "BUSCANDO GLOBAL: $labelGlobal" "LENDO LISTA DE PIPELINES: 100.00%"

    cat $TEMP_OUTPUT_FIND

    printf '%s|%s\n' $(seq -s '-' 93 | tr -d [:digit:]) $(seq -s '-' 41 | tr -d [:digit:])
    printf '%-92s|%s\n' "TOTAL ENCONTRADO" "$x"
    printf '%s|%s\n' $(seq -s '-' 93 | tr -d [:digit:]) $(seq -s '-' 41 | tr -d [:digit:])

    echo "$(date +%Y%m%d-%H%M%S.%s):FIND_GLOBAL:Total encontrado: $x." >> $LOG
    echo "$(date +%Y%m%d-%H%M%S.%s):FIND_GLOBAL:" >> $LOG
    echo "$(date +%Y%m%d-%H%M%S.%s):FIND_GLOBAL:Função finalizada." >> $LOG
}

function multiplas_globals(){
    
    echo "$(date +%Y%m%d-%H%M%S.%s):MULTIPLAS_GLOBALS:" >> $LOG
    echo "$(date +%Y%m%d-%H%M%S.%s):MULTIPLAS_GLOBALS:Iniciando função." >> $LOG
    if [ -e $INPUT_FILE_MULT_GLOBALS ]; then
        echo "$(date +%Y%m%d-%H%M%S.%s):MULTIPLAS_GLOBALS:Chamando a função -> list_pipelines()." >> $LOG
        # chama listagem de pipelines
        list_pipelines
        
        echo "$(date +%Y%m%d-%H%M%S.%s):MULTIPLAS_GLOBALS:Percorre arquivo : $INPUT_FILE_MULT_GLOBALS." >> $LOG
        for global in $(cat $INPUT_FILE_MULT_GLOBALS); \
        do
            labelGlobal=$global
            printf '\n\n%s\n' $(seq -s '-' 134 | tr -d [:digit:])
            printf '%s\n' "BUSCANDO GLOBAL: $labelGlobal"
            echo "$(date +%Y%m%d-%H%M%S.%s):MULTIPLAS_GLOBALS:BUSCANDO GLOBAL: $labelGlobal." >> $LOG
            printf '%s\n' $(seq -s '-' 134 | tr -d [:digit:])
            BYPASS_LIST_PIPELINES=1
            echo "$(date +%Y%m%d-%H%M%S.%s):MULTIPLAS_GLOBALS:Chamando a função -> find_global()." >> $LOG
            find_global \
        ;done
    else
        echo -e "\033[01;33mArquivo não encontrado: [$INPUT_FILE_MULT_GLOBALS]\033[00;37m"
        echo "$(date +%Y%m%d-%H%M%S.%s):MULTIPLAS_GLOBALS:Arquivo não encontrado: $INPUT_FILE_MULT_GLOBALS." >> $LOG
    fi

    echo "$(date +%Y%m%d-%H%M%S.%s):MULTIPLAS_GLOBALS:" >> $LOG
    echo "$(date +%Y%m%d-%H%M%S.%s):MULTIPLAS_GLOBALS:Função finalizada." >> $LOG
}

function find_capsule(){
    
    echo "$(date +%Y%m%d-%H%M%S.%s):FIND_CAPSULE:" >> $LOG
    echo "$(date +%Y%m%d-%H%M%S.%s):FIND_CAPSULE:Iniciando função." >> $LOG
    echo "$(date +%Y%m%d-%H%M%S.%s):FIND_CAPSULE:Verifica se precisa chamar a função list_pipelines()." >> $LOG
    # chama listagem de pipelines
    if [ $BYPASS_LIST_PIPELINES -eq 0 ]; then
        echo "$(date +%Y%m%d-%H%M%S.%s):FIND_CAPSULE:Chamando a função -> list_pipelines()." >> $LOG
        list_pipelines
    fi

    printf '%s|%s|%s|%s\n' $(seq -s '-' 41 | tr -d [:digit:]) $(seq -s '-' 41 | tr -d [:digit:]) $(seq -s '-' 11 | tr -d [:digit:]) $(seq -s '-' 41 | tr -d [:digit:]) > $TEMP_OUTPUT_FIND
    printf '%-40s|%-40s|%-10s|%s\n' "NAME" "PIPELINE-ID" "VERSION" "ARCHIVED" >> $TEMP_OUTPUT_FIND
    printf '%s|%s|%s|%s\n' $(seq -s '-' 41 | tr -d [:digit:]) $(seq -s '-' 41 | tr -d [:digit:]) $(seq -s '-' 11 | tr -d [:digit:]) $(seq -s '-' 41 | tr -d [:digit:]) >> $TEMP_OUTPUT_FIND

    capsule=$labelCapsule
    cap=$lbCapsule
    echo "$(date +%Y%m%d-%H%M%S.%s):FIND_CAPSULE:Capsula a ser buscada: $cap." >> $LOG
    x=0
    i=0
    p=`echo "scale=2;100/$TOTAL_LIST_PIPELINES" | bc`
    printf '\n'
    while read name pipelineId version archived;
    do
        let "i = i +1"
        z=`echo "scale=2;$p*$i" | bc`
        printf '%s\n%s\n' "BUSCANDO CAPSULA: $lbCapsule" "LENDO PIPELINES: $z%"
        count=`digibeectl get pipelines --pipeline-id $pipelineId --flowspec | grep -a $capsule -o | wc -l`
        #count=`digibeectl get pipelines --pipeline-id $pipelineId --flowspec | grep -a 'capsule":"get-customer-id' -o | wc -l`
        if [ $count -gt 0 ]; then 
            printf '%-40s|%-40s|%-10s|%s\n' $name $pipelineId $version $archived >> $TEMP_OUTPUT_FIND
            echo "$(date +%Y%m%d-%H%M%S.%s):FIND_CAPSULE:Pipeline encontrado: $(printf '%s|%s|%s|%s' $name $pipelineId $version $archived)." >> $LOG
            let "x = x +1"
        fi
        #printf '%-40s|%-40s|%-10s|%s\n' $name $pipelineId $version $archived
        #break
        clear
    done < $OUTPUT_FILE_LIST_PIPELINES

    clear
    printf '%s\n%s\n\n' "BUSCANDO CAPSULA: $lbCapsule" "LENDO PIPELINES: 100.00%"

    cat $TEMP_OUTPUT_FIND

    printf '%s|%s\n' $(seq -s '-' 93 | tr -d [:digit:]) $(seq -s '-' 41 | tr -d [:digit:])
    printf '%-92s|%s\n' "TOTAL ENCONTRADO" "$x"
    printf '%s|%s\n' $(seq -s '-' 93 | tr -d [:digit:]) $(seq -s '-' 41 | tr -d [:digit:])

    echo "$(date +%Y%m%d-%H%M%S.%s):FIND_CAPSULE:Total encontrado: $x." >> $LOG
    echo "$(date +%Y%m%d-%H%M%S.%s):FIND_CAPSULE:" >> $LOG
    echo "$(date +%Y%m%d-%H%M%S.%s):FIND_CAPSULE:Função finalizada." >> $LOG
}

function multiplas_capsule(){
    
    echo "$(date +%Y%m%d-%H%M%S.%s):MULTIPLAS_CAPSULE:" >> $LOG
    echo "$(date +%Y%m%d-%H%M%S.%s):MULTIPLAS_CAPSULE:Iniciando função." >> $LOG
    if [ -e $INPUT_FILE_MULT_CAPSULES ]; then
        echo "$(date +%Y%m%d-%H%M%S.%s):MULTIPLAS_CAPSULE:Chamando a função -> list_pipelines()." >> $LOG
        # chama listagem de pipelines
        list_pipelines
        
        echo "$(date +%Y%m%d-%H%M%S.%s):MULTIPLAS_CAPSULE:Percorre arquivo : $INPUT_FILE_MULT_CAPSULES." >> $LOG
        for capsule in $(cat $INPUT_FILE_MULT_CAPSULES); \
        do
            lbCapsule=$capsule
            labelCapsule='"capsule":"'$capsule""
            printf '\n\n%s\n' $(seq -s '-' 134 | tr -d [:digit:])
            printf '%s\n' "BUSCANDO CAPSULA: $lbCapsule"
            echo "$(date +%Y%m%d-%H%M%S.%s):MULTIPLAS_CAPSULE:BUSCANDO CAPSULA: $lbCapsule." >> $LOG
            printf '%s\n' $(seq -s '-' 134 | tr -d [:digit:])
            BYPASS_LIST_PIPELINES=1
            echo "$(date +%Y%m%d-%H%M%S.%s):MULTIPLAS_CAPSULE:Chamando a função -> find_capsulel()." >> $LOG
            find_capsule \
        ;done
    else
        echo -e "\033[01;33mArquivo não encontrado: [$INPUT_FILE_MULT_CAPSULES]\033[00;37m"
        echo "$(date +%Y%m%d-%H%M%S.%s):MULTIPLAS_CAPSULE:Arquivo não encontrado: $INPUT_FILE_MULT_CAPSULES." >> $LOG
    fi

    echo "$(date +%Y%m%d-%H%M%S.%s):MULTIPLAS_CAPSULE:" >> $LOG
    echo "$(date +%Y%m%d-%H%M%S.%s):MULTIPLAS_CAPSULE:Função finalizada." >> $LOG
}

function find_account(){
    
    echo "$(date +%Y%m%d-%H%M%S.%s):FIND_ACCOUNT:" >> $LOG
    echo "$(date +%Y%m%d-%H%M%S.%s):FIND_ACCOUNT:Iniciando função." >> $LOG
    echo "$(date +%Y%m%d-%H%M%S.%s):FIND_ACCOUNT:Verifica se precisa chamar a função list_pipelines()." >> $LOG
    # chama listagem de pipelines
    if [ $BYPASS_LIST_PIPELINES -eq 0 ]; then
        echo "$(date +%Y%m%d-%H%M%S.%s):FIND_ACCOUNT:Chamando a função -> list_pipelines()." >> $LOG
        list_pipelines
    fi
    

    #printf '%s|%s|%s|%s\n' $(seq -s '-' 41 | tr -d [:digit:]) $(seq -s '-' 41 | tr -d [:digit:]) $(seq -s '-' 11 | tr -d [:digit:]) $(seq -s '-' 41 | tr -d [:digit:])
    #printf '%-40s|%-40s|%-10s|%s\n' "NAME" "PIPELINE-ID" "VERSION" "ARCHIVED"
    #printf '%s|%s|%s|%s\n' $(seq -s '-' 41 | tr -d [:digit:]) $(seq -s '-' 41 | tr -d [:digit:]) $(seq -s '-' 11 | tr -d [:digit:]) $(seq -s '-' 41 | tr -d [:digit:])

    printf '%s|%s|%s|%s\n' $(seq -s '-' 41 | tr -d [:digit:]) $(seq -s '-' 41 | tr -d [:digit:]) $(seq -s '-' 11 | tr -d [:digit:]) $(seq -s '-' 41 | tr -d [:digit:]) > $TEMP_OUTPUT_FIND
    printf '%-40s|%-40s|%-10s|%s\n' "NAME" "PIPELINE-ID" "VERSION" "ARCHIVED" >> $TEMP_OUTPUT_FIND
    printf '%s|%s|%s|%s\n' $(seq -s '-' 41 | tr -d [:digit:]) $(seq -s '-' 41 | tr -d [:digit:]) $(seq -s '-' 11 | tr -d [:digit:]) $(seq -s '-' 41 | tr -d [:digit:]) >> $TEMP_OUTPUT_FIND
    
    echo "$(date +%Y%m%d-%H%M%S.%s):FIND_ACCOUNT:Account a ser buscada: $labelAccount." >> $LOG
    x=0
    i=0
    p=`echo "scale=2;100/$TOTAL_LIST_PIPELINES" | bc`
    printf '\n'
    while read name pipelineId version archived;
    do
        let "i = i +1"
        z=`echo "scale=2;$p*$i" | bc`
        printf '%s\n%s\n' "BUSCANDO ACCOUNT: $labelAccount" "LENDO PIPELINES: $z%"
        #sleep 1
        count=`digibeectl get pipelines --pipeline-id $pipelineId --flowspec | grep -a -e 'accountLabel":"'$labelAccount -e 'custom-1":"'$labelAccount -e 'custom-2":"'$labelAccount -e 'accountLabels":.*'$labelAccount -o | wc -l`
        if [ $count -gt 0 ]; then 
            printf '%-40s|%-40s|%-10s|%s\n' $name $pipelineId $version $archived >> $TEMP_OUTPUT_FIND
            echo "$(date +%Y%m%d-%H%M%S.%s):FIND_ACCOUNT:Pipeline encontrado: $(printf '%s|%s|%s|%s' $name $pipelineId $version $archived)." >> $LOG
            let "x = x +1"
        fi
        clear
    done < $OUTPUT_FILE_LIST_PIPELINES
    
    clear
    printf '%s\n%s\n\n' "BUSCANDO ACCOUNT: $labelAccount" "LENDO PIPELINES: 100.00%"

    cat $TEMP_OUTPUT_FIND
    printf '%s|%s\n' $(seq -s '-' 93 | tr -d [:digit:]) $(seq -s '-' 41 | tr -d [:digit:])
    printf '%-92s|%s\n' "TOTAL ENCONTRADO" "$x"
    printf '%s|%s\n' $(seq -s '-' 93 | tr -d [:digit:]) $(seq -s '-' 41 | tr -d [:digit:])

    echo "$(date +%Y%m%d-%H%M%S.%s):FIND_ACCOUNT:Total encontrado: $x." >> $LOG
    echo "$(date +%Y%m%d-%H%M%S.%s):FIND_ACCOUNT:" >> $LOG
    echo "$(date +%Y%m%d-%H%M%S.%s):FIND_ACCOUNT:Função finalizada." >> $LOG
}

function multiplas_accounts(){
    
    echo "$(date +%Y%m%d-%H%M%S.%s):MULTIPLAS_ACCOUNTS:" >> $LOG
    echo "$(date +%Y%m%d-%H%M%S.%s):MULTIPLAS_ACCOUNTS:Iniciando função." >> $LOG
    if [ -e $INPUT_FILE_MULT_ACCOUNTS ]; then
        echo "$(date +%Y%m%d-%H%M%S.%s):MULTIPLAS_ACCOUNTS:Chamando a função -> list_pipelines()." >> $LOG
        # chama listagem de pipelines
        list_pipelines
        
        echo "$(date +%Y%m%d-%H%M%S.%s):MULTIPLAS_ACCOUNTS:Percorre arquivo : $INPUT_FILE_MULT_ACCOUNTS." >> $LOG
        for account in $(cat $INPUT_FILE_MULT_ACCOUNTS); \
        do
            labelAccount=$account
            printf '\n\n%s\n' $(seq -s '-' 134 | tr -d [:digit:])
            printf '%s\n' "BUSCANDO ACCOUNT: $labelAccount"
            echo "$(date +%Y%m%d-%H%M%S.%s):MULTIPLAS_ACCOUNTS:BUSCANDO ACCOUNT: $labelAccount." >> $LOG
            printf '%s\n' $(seq -s '-' 134 | tr -d [:digit:])
            BYPASS_LIST_PIPELINES=1
            echo "$(date +%Y%m%d-%H%M%S.%s):MULTIPLAS_ACCOUNTS:Chamando a função -> find_account()." >> $LOG
            find_account \
        ;done
    else
        echo -e "\033[01;33mArquivo não encontrado: [$INPUT_FILE_MULT_ACCOUNTS]\033[00;37m"
        echo "$(date +%Y%m%d-%H%M%S.%s):MULTIPLAS_ACCOUNTS:Arquivo não encontrado: $INPUT_FILE_MULT_ACCOUNTS." >> $LOG
    fi

    echo "$(date +%Y%m%d-%H%M%S.%s):MULTIPLAS_ACCOUNTS:" >> $LOG
    echo "$(date +%Y%m%d-%H%M%S.%s):MULTIPLAS_ACCOUNTS:Função finalizada." >> $LOG
}

function read_list_deployment(){
    echo "$(date +%Y%m%d-%H%M%S.%s):READ_LIST_DEPLOYMENT:" >> $LOG
    echo "$(date +%Y%m%d-%H%M%S.%s):READ_LIST_DEPLOYMENT:Iniciando função." >> $LOG
    echo "$(date +%Y%m%d-%H%M%S.%s):READ_LIST_DEPLOYMENT:Chamando a função -> list_deployment()." >> $LOG
    list_deployment
    printf '\n\n%-40s|%-40s|%-10s|%-20s|%-15s|%-15s|%-10s|%-20s|%s\n' $(seq -s '-' 41 | tr -d [:digit:]) $(seq -s '-' 41 | tr -d [:digit:]) $(seq -s '-' 11 | tr -d [:digit:]) $(seq -s '-' 21 | tr -d [:digit:]) $(seq -s '-' 16 | tr -d [:digit:]) $(seq -s '-' 16 | tr -d [:digit:]) $(seq -s '-' 11 | tr -d [:digit:]) $(seq -s '-' 21 | tr -d [:digit:]) $(seq -s '-' 21 | tr -d [:digit:])
    printf '%-40s|%-40s|%-10s|%-20s|%-15s|%-15s|%-10s|%-20s|%s\n' "NAME" "PIPELINE-ID" "VERSION" "STATUS" "REPLICAS" "CONSUMERS" "SIZE" "ENVIRONMENT" "RTUs"
    printf '%-40s|%-40s|%-10s|%-20s|%-15s|%-15s|%-10s|%-20s|%s\n' $(seq -s '-' 41 | tr -d [:digit:]) $(seq -s '-' 41 | tr -d [:digit:]) $(seq -s '-' 11 | tr -d [:digit:]) $(seq -s '-' 21 | tr -d [:digit:]) $(seq -s '-' 16 | tr -d [:digit:]) $(seq -s '-' 16 | tr -d [:digit:]) $(seq -s '-' 11 | tr -d [:digit:]) $(seq -s '-' 21 | tr -d [:digit:]) $(seq -s '-' 21 | tr -d [:digit:])
    IFS=" "
    totalRtus=0
    z=0
    echo "$(date +%Y%m%d-%H%M%S.%s):READ_LIST_DEPLOYMENT:Percorre arquivo : $OUTPUT_FILE_LIST_DEPLOYMENT_PIPELINES." >> $LOG
    while read name pipelineId version status replicas consumers size environment;
    do  
        rtu=0
        if [ $size == "SMALL" ]; then
            y=1
            totalReplicas=`echo $replicas | cut -d '/' -f1`
            totalReplicas=`printf '%d' $totalReplicas`
            rtu=$(($y*$totalReplicas))
            totalRtus=$(($totalRtus+$rtu))
        fi

        if [ $size == "MEDIUM" ]; then
            y=2
            totalReplicas=`echo $replicas | cut -d '/' -f1`
            totalReplicas=`printf '%d' $totalReplicas`
            rtu=$(($y*$totalReplicas))
            totalRtus=$(($totalRtus+$rtu))
        fi

        if [ $size == "LARGE" ]; then
            y=4
            totalReplicas=`echo $replicas | cut -d '/' -f1`
            totalReplicas=`printf '%d' $totalReplicas`
            rtu=$(($y*$totalReplicas))
            totalRtus=$(($totalRtus+$rtu))
        fi

        printf '%-40s|%-40s|%-10s|%-20s|%-15s|%-15s|%-10s|%-20s|%s\n' $name $pipelineId $version $status $replicas $consumers $size $environment $rtu
        echo "$(date +%Y%m%d-%H%M%S.%s):READ_LIST_DEPLOYMENT:Deploys encontrados: $(printf '%s|%s|%s|%s|%s|%s|%s|%s|%s' $name $pipelineId $version $status $replicas $consumers $size $environment $rtu)." >> $LOG
        let "z = z +1"
    done < $OUTPUT_FILE_LIST_DEPLOYMENT_PIPELINES
    printf '%-40s|%-40s|%-10s|%-20s|%-15s|%-15s|%-10s|%-20s|%s\n' $(seq -s '-' 41 | tr -d [:digit:]) $(seq -s '-' 41 | tr -d [:digit:]) $(seq -s '-' 11 | tr -d [:digit:]) $(seq -s '-' 21 | tr -d [:digit:]) $(seq -s '-' 16 | tr -d [:digit:]) $(seq -s '-' 16 | tr -d [:digit:]) $(seq -s '-' 11 | tr -d [:digit:]) $(seq -s '-' 21 | tr -d [:digit:]) $(seq -s '-' 21 | tr -d [:digit:])
    printf '\n\n%s:\t%-59s\n' "TOTAL DEPLOYMENTS" "$z"
    printf '%s:\t%-59s\n' "TOTAL RTUS" "$totalRtus"

    echo "$(date +%Y%m%d-%H%M%S.%s):READ_LIST_DEPLOYMENT:Total Deployments: $z | Total RTUs: $totalRtus." >> $LOG
    echo "$(date +%Y%m%d-%H%M%S.%s):READ_LIST_DEPLOYMENT:" >> $LOG
    echo "$(date +%Y%m%d-%H%M%S.%s):READ_LIST_DEPLOYMENT:Função finalizada." >> $LOG
}

function list_deployment(){
    echo "$(date +%Y%m%d-%H%M%S.%s):LIST_DEPLOYMENT:" >> $LOG
    echo "$(date +%Y%m%d-%H%M%S.%s):LIST_DEPLOYMENT:Iniciando função." >> $LOG
    printf '\n'
    if [ -z $environment ]; then
        environment=test
    fi
    echo "$(date +%Y%m%d-%H%M%S.%s):LIST_DEPLOYMENT:Verificando se existi o arquivo: $OUTPUT_FILE_LIST_DEPLOYMENT_PIPELINES." >> $LOG
    if [ -e $OUTPUT_FILE_LIST_DEPLOYMENT_PIPELINES ]; then
        echo "$(date +%Y%m%d-%H%M%S.%s):LIST_DEPLOYMENT:Excluindo arquivo." >> $LOG
        rm $OUTPUT_FILE_LIST_DEPLOYMENT_PIPELINES
        RET=$?
        if [ $RET -eq 0 ]; then
            echo "$(date +%Y%m%d-%H%M%S.%s):LIST_DEPLOYMENT:Arquivo excluido com sucesso." >> $LOG 
        else
            echo "$(date +%Y%m%d-%H%M%S.%s):LIST_DEPLOYMENT:Error ao excluir arquivo." >> $LOG
        fi
    fi
    echo "$(date +%Y%m%d-%H%M%S.%s):LIST_DEPLOYMENT:Buscando deploys ambiente: $environment." >> $LOG
    digibeectl get deployment --environment $environment | sed '1d' > $OUTPUT_FILE_LIST_DEPLOYMENT_PIPELINES
    RET=$?
    if [ $RET -eq 0 ]; then 
        echo -e "\033[01;32m Lista de deploys carregada com sucesso.\033[00;37m"
        echo "$(date +%Y%m%d-%H%M%S.%s):LIST_DEPLOYMENT:Lista de deploys carregada com sucesso." >> $LOG
    else
        echo -e "\033[01;33mErro ao carregar lista de deploys.\033[00;37m"
        echo "$(date +%Y%m%d-%H%M%S.%s):LIST_DEPLOYMENT:Erro ao carregar lista de deploys." >> $LOG
        exit 1
    fi
    printf '\n'

    echo "$(date +%Y%m%d-%H%M%S.%s):LIST_DEPLOYMENT:" >> $LOG
    echo "$(date +%Y%m%d-%H%M%S.%s):LIST_DEPLOYMENT:Função finalizada." >> $LOG
}

function deployment(){
    echo "$(date +%Y%m%d-%H%M%S.%s):DEPLOYMENT:" >> $LOG
    echo "$(date +%Y%m%d-%H%M%S.%s):DEPLOYMENT:Iniciando função." >> $LOG
    # create deployment --pipeline-id 5a64c446-a6bb-4bbf-808e-7cea667f7126 --pipeline-size SMALL --consumers 10 -e test --redeploy --wait
    # digibeectl get deployment --name n26-authorized-customers -e test
    echo "$(date +%Y%m%d-%H%M%S.%s):DEPLOYMENT:Verificando se existe o arquivo com pipelines para deploy: $INPUT_FILE_MULT_DEPLOYS." >> $LOG
    if [ -e $INPUT_FILE_MULT_DEPLOYS ]; then

        echo "$(date +%Y%m%d-%H%M%S.%s):DEPLOYMENT:Arquivo existe." >> $LOG
        x=0
        z=0

        printf '\n\n%s+%s+%s+%s+%s+%s\n' $(seq -s '-' 71 | tr -d [:digit:]) $(seq -s '-' 21 | tr -d [:digit:]) $(seq -s '-' 21 | tr -d [:digit:]) $(seq -s '-' 21 | tr -d [:digit:]) $(seq -s '-' 21 | tr -d [:digit:]) $(seq -s '-' 21 | tr -d [:digit:]) > $OUTPUT_PIPELINES_DEPLOYS
        printf '%-70s|%-20s|%-20s|%-20s|%-20s|%-20s\n' "PIPELINE_NAME" "VERSION" "SIZE" "CONSUMERS" "REPLICAS" "STATUS" >> $OUTPUT_PIPELINES_DEPLOYS
        printf '%s+%s+%s+%s+%s+%s\n' $(seq -s '-' 71 | tr -d [:digit:]) $(seq -s '-' 21 | tr -d [:digit:]) $(seq -s '-' 21 | tr -d [:digit:]) $(seq -s '-' 21 | tr -d [:digit:]) $(seq -s '-' 21 | tr -d [:digit:]) $(seq -s '-' 21 | tr -d [:digit:]) >> $OUTPUT_PIPELINES_DEPLOYS


        while read linha; #pipelineName pipelineVersion environment size consumers replicas;
        do
            #echo $linha
            pipelineName=`echo $linha | cut -d ',' -f1`
            pipelineVersion=`echo $linha | cut -d ',' -f2`
            versionMajor=`echo $pipelineVersion | sed 's/\./\\\./g'`
            environment=`echo $linha | cut -d ',' -f3`
            size=`echo $linha | cut -d ',' -f4`
            consumers=`echo $linha | cut -d ',' -f5`
            replicas=`echo $linha | cut -d ',' -f6`
	        multiInstance=`echo $linha | cut -d ',' -f7`

            if [ "$size" == "S" ]; then 
                size="SMALL"
                if [ -z $consumers ]; then
                    consumers=10
                elif [ $consumers -gt 10 ]; then
                    consumers=10
                else
                    consumers=$consumers
                fi
            elif [ "$size" == "M" ]; then
                size="MEDIUM"
                if [ -z $consumers ]; then
                    consumers=20
                elif [ $consumers -gt 20 ]; then
                    consumers=20
                else
                    consumers=$consumers
                fi
            elif [ "$size" == "L" ]; then
                size="LARGE"
                if [ -z $consumers ]; then
                    consumers=40
                elif [ $consumers -gt 40 ]; then
                    consumers=40
                else
                    consumers=$consumers
                fi
            else
                size="SMALL"
                if [ -z $consumers ]; then
                    consumers=10
                elif [ $consumers -gt 10 ]; then
                    consumers=10
                else
                    consumers=$consumers
                fi
            fi
            
            if [ $replicas -eq 0 ]; then
                replicas=1
            fi
	    
            if [ -z $multiInstance ]; then
                multiInstance=0
            fi	

            echo "$(date +%Y%m%d-%H%M%S.%s):DEPLOYMENT:Chamando a função -> list_deployment()." >> $LOG
            environment=$environment
            list_deployment
            
            PIPELINE_NAME=$pipelineName
            PIPELINE_VERSION_MAJOR=`echo $pipelineVersion | cut -d '.' -f1`
            PIPELINE_VERSION_MAJOR=`printf '%d' $PIPELINE_VERSION_MAJOR`
            
            if [ $multiInstance -eq 0 ]; then
                pipelineName=$pipelineName
            else
                pipelineName=`echo $pipelineName-$multiInstance`
            fi

            echo "$(date +%Y%m%d-%H%M%S.%s):DEPLOYMENT:Chamando a função -> full_list_pipeline()." >> $LOG
            full_list_pipeline

            checkDeploy=`cat $OUTPUT_FILE_LIST_DEPLOYMENT_PIPELINES | sed -n /^$pipelineName.*$PIPELINE_VERSION_MAJOR\\\..*/p | wc -l`
            checkDeploy=`printf '%d' $checkDeploy`
            countSuccess=0
            countFailed=0
            while read name pipelineId version archived;
            do 
                if [[ "$version" == "$pipelineVersion" && "$name" == "$pipelineName" ]]; then
                    
                    x=0
                    #echo $name-$version-$pipelineId
                    if [ $checkDeploy -eq 0 ]; then
                        echo "$(date +%Y%m%d-%H%M%S.%s):DEPLOYMENT:Deploy pronto para iniciar -> $pipeline|$pipelineId|$pipelineVersion|$size|$consumers|$replicas|IN_PROGRESS" >> $LOG
                        #digibeectl create deployment --pipeline-id $pipelineId --pipeline-size $size --consumers $consumers -e $environment --replicas $replicas --wait
                        digibeectl create deployment --pipeline-id $pipelineId --pipeline-size $size --consumers $consumers -e $environment --replicas $replicas
                        echo "$(date +%Y%m%d-%H%M%S.%s):DEPLOYMENT:Deploy iniciado" >> $LOG
                        sleep 10
                        while true;
                        do

                            # digibeectl get deployment --name "n26-home" | sed s/^$p.[\s].*//g | grep -v '^[\s\t]*$'
                            #fator_1=`digibeectl get deployment --name $pipelineName | sed 1d | awk -F " " '{print $5}' | cut -d '/' -f1`
                            #fator_2=`digibeectl get deployment --name $pipelineName | sed 1d | awk -F " " '{print $5}' | cut -d '/' -f2`
                            # digibeectl get deployment --name evt-error-training-walter-moura --environment test | sed 1d | sed -n '/^$pipelineName.*$versionMajor/p'
                            #fator_1=`digibeectl get deployment --name "$pipelineName" --environment "$environment" | sed '1d' | sed s/^$pipelineName.[\s].*//g | grep -v '^[\s\t]*$' | awk -F " " '{print $5}' | cut -d '/' -f1`
                            #fator_1=$replicas
                            #fator_2=`digibeectl get deployment --name "$pipelineName" --environment "$environment" | sed '1d' | sed s/^$pipelineName.[\s].*//g | grep -v '^[\s\t]*$' | awk -F " " '{print $5}' | cut -d '/' -f2`
                            fator_1=`digibeectl get deployment --name "$pipelineName" --environment "$environment" | sed -n /^$pipelineName.*$versionMajor/p | grep -v '^[\s\t]*$' | awk -F " " '{print $5}' | cut -d '/' -f1`
                            fator_2=`digibeectl get deployment --name "$pipelineName" --environment "$environment" | sed -n /^$pipelineName.*$versionMajor/p | grep -v '^[\s\t]*$' | awk -F " " '{print $5}' | cut -d '/' -f2`

                            if [ $fator_1 -eq $fator_2 ]; then
                                clear
                                printf '%-70s|%-20s|%-20s|%-20s|%-20s|%-20s\n' $pipelineName $version $size $consumers $replicas "COMPLETED" >> $OUTPUT_PIPELINES_DEPLOYS
                                #let "z = z +1"
                                break
                            else
                                clear
                                printf '\n\n%s+%s+%s+%s+%s+%s\n' $(seq -s '-' 71 | tr -d [:digit:]) $(seq -s '-' 21 | tr -d [:digit:]) $(seq -s '-' 21 | tr -d [:digit:]) $(seq -s '-' 21 | tr -d [:digit:]) $(seq -s '-' 21 | tr -d [:digit:]) $(seq -s '-' 21 | tr -d [:digit:])
                                printf '%-70s|%-20s|%-20s|%-20s|%-20s|%-20s\n' "PIPELINE_NAME" "VERSION" "SIZE" "CONSUMERS" "REPLICAS" "STATUS"
                                printf '%s+%s+%s+%s+%s+%s\n' $(seq -s '-' 71 | tr -d [:digit:]) $(seq -s '-' 21 | tr -d [:digit:]) $(seq -s '-' 21 | tr -d [:digit:]) $(seq -s '-' 21 | tr -d [:digit:]) $(seq -s '-' 21 | tr -d [:digit:]) $(seq -s '-' 21 | tr -d [:digit:])
                                printf '%-70s|%-20s|%-20s|%-20s|%-20s|%10s\n' $pipelineName $version $size $consumers $replicas "${PERC:$x:1}"
                                #echo -e "\033[01;32mAguardando finalizar deploy->[${PERC:$x:1}]\033[00;37m"
                            fi

                            if [ $x -eq 5 ]; then
                                x=0
                            else 
                                let "x = x +1"
                            fi
                        done
                        echo "$(date +%Y%m%d-%H%M%S.%s):DEPLOYMENT:Deploy finalizado -> $pipeline|$pipelineId|$pipelineVersion|$size|$consumers|$replicas|COMPLETED" >> $LOG
                    else
                        echo "$(date +%Y%m%d-%H%M%S.%s):DEPLOYMENT:Re-Deploy pronto para iniciar -> $pipeline|$pipelineId|$pipelineVersion|$size|$consumers|$replicas|IN_PROGRESS" >> $LOG
                        #digibeectl create deployment --pipeline-id $pipelineId --pipeline-size $size --consumers $consumers -e $environment --redeploy --replicas $replicas --wait
                        digibeectl create deployment --pipeline-id $pipelineId --pipeline-size $size --consumers $consumers -e $environment --redeploy --replicas $replicas
                        echo "$(date +%Y%m%d-%H%M%S.%s):DEPLOYMENT:Re-Deploy iniciado" >> $LOG
                        sleep 10
                        while true;
                        do
                            
                            #fator_1=`digibeectl get deployment --name "$pipelineName" --environment "$environment" | sed '1d' | sed s/^$pipelineName.[\s].*//g | grep -v '^[\s\t]*$' | awk -F " " '{print $5}' | cut -d '/' -f1`
                            #fator_1=$replicas
                            #fator_2=`digibeectl get deployment --name "$pipelineName" --environment "$environment" | sed '1d' | sed s/^$pipelineName.[\s].*//g | grep -v '^[\s\t]*$' | awk -F " " '{print $5}' | cut -d '/' -f2`

                            #fator_1=`digibeectl get deployment --name "$pipelineName" --environment "$environment" | sed 1d | sed -n /^$pipelineName.*$versionMajor/p | grep -v '^[\s\t]*$' | awk -F " " '{print $5}' | cut -d '/' -f1`
                            fator_1=$replicas
                            fator_2=`digibeectl get deployment --name "$pipelineName" --environment "$environment" | sed 1d | sed -n /^$pipelineName.*$versionMajor/p | grep -v '^[\s\t]*$' | awk -F " " '{print $5}' | cut -d '/' -f2`

                            if [ $fator_1 -eq $fator_2 ]; then
                                clear
                                printf '%-70s|%-20s|%-20s|%-20s|%-20s|%-20s\n' $pipelineName $version $size $consumers $replicas "COMPLETED" >> $OUTPUT_PIPELINES_DEPLOYS
                                #let "z = z +1"
                                break
                            else
                                clear
                                printf '\n\n%s+%s+%s+%s+%s+%s\n' $(seq -s '-' 71 | tr -d [:digit:]) $(seq -s '-' 21 | tr -d [:digit:]) $(seq -s '-' 21 | tr -d [:digit:]) $(seq -s '-' 21 | tr -d [:digit:]) $(seq -s '-' 21 | tr -d [:digit:]) $(seq -s '-' 21 | tr -d [:digit:])
                                printf '%-70s|%-20s|%-20s|%-20s|%-20s|%-20s\n' "PIPELINE_NAME" "VERSION" "SIZE" "CONSUMERS" "REPLICAS" "STATUS"
                                printf '%s+%s+%s+%s+%s+%s\n' $(seq -s '-' 71 | tr -d [:digit:]) $(seq -s '-' 21 | tr -d [:digit:]) $(seq -s '-' 21 | tr -d [:digit:]) $(seq -s '-' 21 | tr -d [:digit:]) $(seq -s '-' 21 | tr -d [:digit:]) $(seq -s '-' 21 | tr -d [:digit:])
                                printf '%-70s|%-20s|%-20s|%-20s|%-20s|%10s\n' $pipelineName $version $size $consumers $replicas "${PERC:$x:1}"
                            fi

                            if [ $x -eq 5 ]; then
                                x=0
                                sleep 1
                            else 
                                let "x = x +1"
                            fi
                        done
                        echo "$(date +%Y%m%d-%H%M%S.%s):DEPLOYMENT:Re-Deploy finalizado -> $pipeline|$pipelineId|$pipelineVersion|$size|$consumers|$replicas|COMPLETED" >> $LOG
                    fi
                    countSuccess=$(($countSuccess+1))
                else
                    countFailed=$(($countFailed+1))
                fi 
            done < $OUTPUT_FILE_FULL_LIST_PIPELINES #| grep $pipelineName

            if [ $countSuccess -eq 0 ]; then
                printf '%-70s|%-20s|%-20s|%-20s|%-20s|%-20s\n' $pipelineName $pipelineVersion $size $consumers $replicas "FAILED" >> $OUTPUT_PIPELINES_DEPLOYS
                echo "$(date +%Y%m%d-%H%M%S.%s):DEPLOYMENT:Re-Deploy finalizado -> $pipeline|$pipelineId|$pipelineVersion|$size|$consumers|$replicas|FAILED" >> $LOG
            fi

        done < $INPUT_FILE_MULT_DEPLOYS
        clear
        cat $OUTPUT_PIPELINES_DEPLOYS
    else
        echo -e "\033[01;33mArquivo de deploy não existe\033[00;37m"
        echo "$(date +%Y%m%d-%H%M%S.%s):DEPLOYMENT:Arquivo não existe." >> $LOG
    fi
    echo "$(date +%Y%m%d-%H%M%S.%s):DEPLOYMENT:" >> $LOG
    echo "$(date +%Y%m%d-%H%M%S.%s):DEPLOYMENT:Função finalizada." >> $LOG
}

function delete_deploy(){
    # digibeectl delete deployment --deployment-id 9aa8c3f5-44bb-4cb8-b83b-1d1606d1fd2e --environment test
    echo "$(date +%Y%m%d-%H%M%S.%s):DELETE_DEPLOY:" >> $LOG
    echo "$(date +%Y%m%d-%H%M%S.%s):DELETE_DEPLOY:Iniciando função." >> $LOG
}

function set_config(){
    echo "$(date +%Y%m%d-%H%M%S.%s):SET_CONFIG:" >> $LOG
    echo "$(date +%Y%m%d-%H%M%S.%s):SET_CONFIG:Iniciando função." >> $LOG
    echo "$(date +%Y%m%d-%H%M%S.%s):SET_CONFIG:Consultados dados de configuração do realm -> $realm." >> $LOG
    sql=`mysql -u ${MYSQL_USER} -p${MYSQL_PASS} ${MYSQL_BD} -h ${MYSQL_HOST} -N -e "SELECT * FROM environment WHERE realm = '$realm'"`
    RET=$?
    if [ $RET -eq 0 ]; then 
        realm=`echo $sql | awk -F ' ' '{print $2}'`
        secretKey=`echo $sql | awk -F ' ' '{print $3}'`
        authKey=`echo $sql | awk -F ' ' '{print $4}'`
        echo "$(date +%Y%m%d-%H%M%S.%s):SET_CONFIG:Setando configurações $realm." >> $LOG
        digibeectl set config --file tokens/$realm-token.json --secret-key $secretKey --auth-key $authKey
        RET=$?
        printf '\n'
        if [ $RET -eq 0 ]; then 
            echo -e "\033[01;32mAmbiente configurado com sucesso: [${realm}]\033[00;37m"
            echo "$(date +%Y%m%d-%H%M%S.%s):SET_CONFIG:Ambiente configurado com sucesso: [${realm}]." >> $LOG
        else
            echo -e "\033[01;33mErro ao configurar ambiente: [${realm}]\033[00;37m"
            echo "$(date +%Y%m%d-%H%M%S.%s):SET_CONFIG:Erro ao configurar ambiente: [${realm}]." >> $LOG
        fi
    else
        echo "$(date +%Y%m%d-%H%M%S.%s):SET_CONFIG:Erro ao buscar dados do realm no banco de dados: [${realm}]->$RET." >> $LOG
        echo -e "\033[01;33mErro ao buscar dados do realm no banco de dados: [${realm}]->$RET\033[00;37m"
    fi
    printf '\n'
    echo "$(date +%Y%m%d-%H%M%S.%s):SET_CONFIG:" >> $LOG
    echo "$(date +%Y%m%d-%H%M%S.%s):SET_CONFIG:Função finalizada." >> $LOG
}

function get_config(){
    echo "$(date +%Y%m%d-%H%M%S.%s):GET_CONFIG:" >> $LOG
    echo "$(date +%Y%m%d-%H%M%S.%s):GET_CONFIG:Iniciando função." >> $LOG
    printf '\n'
    echo -e "$(date +%Y%m%d-%H%M%S.%s):GET_CONFIG:Carregando informações do digibeectl->[\n$(digibeectl get config)]." >> $LOG
    digibeectl get config
    printf '\n'
    echo -e "$(date +%Y%m%d-%H%M%S.%s):GET_CONFIG:Carregando informações do realm configurado->[\n$(digibeectl get realm)]." >> $LOG
    digibeectl get realm
    echo "$(date +%Y%m%d-%H%M%S.%s):GET_CONFIG:" >> $LOG
    echo "$(date +%Y%m%d-%H%M%S.%s):GET_CONFIG:Função finalizada." >> $LOG
}

function help(){

    echo "$(date +%Y%m%d-%H:%M:%S.%s):fnHelp:Start function fnHelp" >> $log

    echo -e "\033[01;33m"
    echo "# USE ./$SCRIPT <param1> <param2> ....... "
    echo ""
    echo ""
    echo "# Parametros de uso:"
    echo ""
    echo "# --menu"
    echo "#   Abrir menu com as opções de uso"
    echo ""
    echo "# --list-pipelines"
    echo "#   Lista os pipelines existentes nos realms"
    echo ""
    echo "# --list-deploys"
    echo "#   Busca os pipelines deployados no ambiente"
    echo "#   Paramentros opcionais:"
    echo "#   --environment"
    echo "#   --environment=test ou --environment=prod, Default=test"
    echo ""
    echo "# --search-global"
    echo "#   Busca uma determinada glabal no realm"
    echo "#   Paramentros opcionais:"
    echo "#   --global"
    echo "#   --global=valor"
    echo "#   Obs.: Caso não informe o paramentro, será buscado as globals dentro do arquivo [global.txt], neste caso pode ser multiplas globals"
    echo ""
    echo "# --search-capsule"
    echo "#   Busca uma determinada capsula no realm"
    echo "#   Paramentros opcionais:"
    echo "#   --capsule"
    echo "#   --capulse=capsule-name"
    echo "#   Obs.: Caso não informe o paramentro, será buscado as globals dentro do arquivo [capsules.txt], neste caso pode ser usado multiplas capsulas"
    echo ""
    echo "# --search-account"
    echo "#   Busca uma determinado account no realm"
    echo "#   Paramentros opcionais:"
    echo "#   --account"
    echo "#   --account=capsule-name"
    echo "#   Obs.: Caso não informe o paramentro, será buscado as globals dentro do arquivo [capsules.txt], neste caso pode ser usado multiplas capsulas"
    echo ""
    echo "# --deploy"
    echo "#   Realiza o deploy/re-deploy dos pipeline existentes no arquivo [pipelines-deploys.csv]"
    echo ""
    echo "# --delete-deploy"
    echo "#   Remove deploys dos pipelines existentes no arquivo [pipelines-remove.csv]"
    echo ""
    echo "# --find-text"
    echo "#   Busca um texto especifico nos pipelines"
    echo "#   Paramentros obrigatórios:"
    echo "#   --text=valor"
    echo ""
    echo ""
    echo "# --get-config"
    echo "#   Exibe as informações de configurações atuais do digibeectl e informações do realm"
    echo ""
    echo "# --set-config"
    echo "#   Paramentros opcionais:"
    echo "#   --realm={nomeDoRealm}"    
    echo "#   Aplica as configurações de ambiente que estão parametrizadas no arquivo [config.conf]"
    echo ""
    echo -e "\033[00;37m"
    exit 1

}

function main(){

    echo "$(date +%Y%m%d-%H%M%S.%s):MAIN:Iniciando função." >> $LOG
    echo "$(date +%Y%m%d-%H%M%S.%s):MAIN:Listando opções." >> $LOG

    echo -e -n "\n[01] - LISTAR PIPELINES\n"
    echo -e -n "[02] - LISTAR DEPLOYS\n"
    echo -e -n "[03] - BUSCAR GLOBALS\n"
    echo -e -n "[04] - DEPLOY/REDEPLOY\n"
    echo -e -n "[05] - BUSCAR CAPSULAS\n"
    echo -e -n "[06] - BUSCAR ACCOUNTS\n"
    echo -e -n "[07] - EXCLUIR DEPLOY\n"
    echo -e -n "[31] - BUSCAR TEXTO\n"
    echo -e -n "[97] - GET CONFIG\n"
    echo -e -n "[98] - SET CONFIG\n"
    echo -e -n "\n[99] - EXIT\n"
    echo -e -n "\nDigite uma opção:"
	read option


    case $option in 
        "01"|"1")
            echo "$(date +%Y%m%d-%H%M%S.%s):MAIN:Opção escolhida: $option." >> $LOG
            echo "$(date +%Y%m%d-%H%M%S.%s):MAIN:Chamando a função -> read_list_pipelines()." >> $LOG
            read_list_pipelines
        ;;
        "02"|"2")
            echo -e -n "\nInforme o ambiente (Default=test):"
            read environment
            if [ -z $environment ]; then
                environment=test
            fi
            echo "$(date +%Y%m%d-%H%M%S.%s):MAIN:Opção escolhida: $option-$environment." >> $LOG
            echo "$(date +%Y%m%d-%H%M%S.%s):MAIN:Chamando a função -> read_list_deployment()." >> $LOG
            #echo -e "\033[01;32mListando Deployments.\033[00;37m"
            read_list_deployment
        ;;
        "03"|"3")
            echo "$(date +%Y%m%d-%H%M%S.%s):MAIN:Opção escolhida: $option." >> $LOG
            echo -e -n "\n[01] - UNICA GLOBAL\n"
            echo -e -n "[02] - MULTIPLAS GLOBALS\n"
            echo -e -n "\n[99] - VOLTAR\n"
            echo -e -n "\nDigite uma opção:"
            read menuGlobal

            case $menuGlobal in
                "01"|"1")
                    echo -e -n "\nInforme a global, somente a label:"
                    read labelGlobal
                    if [ -z $labelGlobal ]; then
                        echo "$(date +%Y%m%d-%H%M%S.%s):MAIN:Global não pode ser vazia: [$labelGlobal]." >> $LOG
                        echo -e "\033[01;31mGlobal não pode ser vazia.\033[00;37m"
                        exit 1
                    fi
                    labelGlobal="{{global.$labelGlobal}}"
                    echo "$(date +%Y%m%d-%H%M%S.%s):MAIN:Iniciando processo de busca da global: [$labelGlobal]." >> $LOG
                    printf '\n\n%s\n' $(seq -s '-' 134 | tr -d [:digit:])
                    printf '%s\n' "BUSCANDO GLOBAL: $labelGlobal"
                    printf '%s\n' $(seq -s '-' 134 | tr -d [:digit:])
                    find_global
                ;;
                "02"|"2")
                    multiplas_globals
                ;;
                "99")
                    main
                ;;
                *)
                    main
                ;;
            esac
        ;;
        "04"|"4")
            echo "$(date +%Y%m%d-%H%M%S.%s):MAIN:Opção escolhida: $option." >> $LOG
            echo "$(date +%Y%m%d-%H%M%S.%s):MAIN:Chamando a função -> deployment()." >> $LOG
            deployment
        ;;
        "05"|"5")
            echo "$(date +%Y%m%d-%H%M%S.%s):MAIN:Opção escolhida: $option." >> $LOG
            echo -e -n "\n[01] - UNICA CAPSULA\n"
            echo -e -n "[02] - MULTIPLAS CAPSULAS\n"
            echo -e -n "\n[99] - VOLTAR\n"
            echo -e -n "\nDigite uma opção:"
            read menuCapsule

            case $menuCapsule in
                "01"|"1")
                    echo -e -n "\nInforme o nome da capsula:"
                    read labelCapsule
                    if [ -z $labelCapsule ]; then
                        echo "$(date +%Y%m%d-%H%M%S.%s):MAIN:Capsula name não pode ser vazia: [$labelCapsule]." >> $LOG
                        echo -e "\033[01;31mCapsula name não pode ser vazia.\033[00;37m"
                        exit 1
                    fi
                    lbCapsule=$labelCapsule
                    labelCapsule='"capsule":"'$labelCapsule""
                    echo "$(date +%Y%m%d-%H%M%S.%s):MAIN:Iniciando processo de busca da capsula: [$lbCapsule]." >> $LOG
                    printf '\n\n%s\n' $(seq -s '-' 134 | tr -d [:digit:])
                    printf '%s\n' "BUSCANDO CAPSULA: $lbCapsule"
                    printf '%s\n' $(seq -s '-' 134 | tr -d [:digit:])
                    find_capsule
                ;;
                "02"|"2")
                    multiplas_capsule
                ;;
                "99")
                    main
                ;;
                *)
                    main
                ;;
            esac
        ;;
        "06"|"6")
            echo "$(date +%Y%m%d-%H%M%S.%s):MAIN:Opção escolhida: $option." >> $LOG
            echo -e -n "\n[01] - UNICA ACCOUNT\n"
            echo -e -n "[02] - MULTIPLAS ACCOUNTS\n"
            echo -e -n "\n[99] - VOLTAR\n"
            echo -e -n "\nDigite uma opção:"
            read menuAccount

            case $menuAccount in
                "01"|"1")
                    echo -e -n "\nInforme o nome da account:"
                    read labelAccount
                    if [ -z $labelAccount ]; then
                        echo "$(date +%Y%m%d-%H%M%S.%s):MAIN:Account name não pode ser vazia: [$labelAccount]." >> $LOG
                        echo -e "\033[01;31mAccount name não pode ser vazia.\033[00;37m"
                        exit 1
                    fi
                    labelAccount=$labelAccount
                    echo "$(date +%Y%m%d-%H%M%S.%s):MAIN:Iniciando processo de busca da account: [$labelAccount]." >> $LOG
                    printf '\n\n%s\n' $(seq -s '-' 134 | tr -d [:digit:])
                    printf '%s\n' "BUSCANDO ACCOUNT: $labelAccount"
                    printf '%s\n' $(seq -s '-' 134 | tr -d [:digit:])
                    find_account
                ;;
                "02"|"2")
                    multiplas_accounts
                ;;
                "99")
                    main
                ;;
                *)
                    main
                ;;
            esac
        ;;
        "07"|"7")
            echo "$(date +%Y%m%d-%H%M%S.%s):MAIN:Opção escolhida: $FUNC." >> $LOG
            echo "$(date +%Y%m%d-%H%M%S.%s):MAIN:Chamando a função -> delete_deploy()." >> $LOG
            exit 1
        ;;
        "31")
            echo "$(date +%Y%m%d-%H%M%S.%s):MAIN:Opção escolhida: $option." >> $LOG
            echo -e -n "\nInforme o texto a ser buscado nos pipelines:"
            read labelText
            if [ -z $labelText ]; then
                echo "$(date +%Y%m%d-%H%M%S.%s):MAIN:Texto não pode ser vazia: [$labelText]." >> $LOG
                echo -e "\033[01;31mGlobal não pode ser vazia.\033[00;37m"
                exit 1
            fi
            labelText=$labelText
            echo "$(date +%Y%m%d-%H%M%S.%s):MAIN:Iniciando processo de busca do texto: [$labelText]." >> $LOG
            printf '\n\n%s\n' $(seq -s '-' 134 | tr -d [:digit:])
            printf '%s\n' "BUSCANDO TEXTO: $labelText"
            printf '%s\n' $(seq -s '-' 134 | tr -d [:digit:])
            find_text
        ;;
        "97")
            echo "$(date +%Y%m%d-%H%M%S.%s):MAIN:Opção escolhida: $option." >> $LOG
            echo "$(date +%Y%m%d-%H%M%S.%s):MAIN:Chamando a função -> get_config()." >> $LOG
            get_config
        ;;
        "98")
            echo "$(date +%Y%m%d-%H%M%S.%s):MAIN:Opção escolhida: $option." >> $LOG
            echo -e -n "\nInforme o realm para configurar:"
            read realm
            if [ -z $realm ]; then
                echo "$(date +%Y%m%d-%H%M%S.%s):MAIN:Ambiente não pode ser vazia: [$realm]." >> $LOG
                echo -e "\033[01;31mAmbiente não pode ser vazia.\033[00;37m"
                exit 1
            fi
            realm=$realm
            echo "$(date +%Y%m%d-%H%M%S.%s):MAIN:Chamando a função -> set_config()." >> $LOG
            set_config

        ;;
        "99")
            exit 1
        ;;
        *)
            echo -e "\033[01;31mResposta diferente do esperado.\033[00;37m"
			exit 1
        ;;
    esac
}

FUNC=$1
VAR_1=$2

case $FUNC in
    "--menu")
        main
    ;; 
    "--list-pipelines")
        echo "$(date +%Y%m%d-%H%M%S.%s):MAIN:Opção escolhida: $FUNC." >> $LOG
        echo "$(date +%Y%m%d-%H%M%S.%s):MAIN:Chamando a função -> read_list_pipelines()." >> $LOG
        read_list_pipelines
    ;;
    "--list-deploys")
        if [ -z $VAR_1 ]; then
            environment=test
        else
            var=`echo $VAR_1 | awk -F '=' '{print $2}'`
            if [ -z $var ]; then
                environment=test
            else
                environment=$var
            fi
        fi
        echo "$(date +%Y%m%d-%H%M%S.%s):MAIN:Opção escolhida: $FUNC-$environment." >> $LOG
        echo "$(date +%Y%m%d-%H%M%S.%s):MAIN:Chamando a função -> read_list_deployment()." >> $LOG
        #echo -e "\033[01;32mListando Deployments.\033[00;37m"
        read_list_deployment
    ;;
    "--search-global")

        if [ -z $VAR_1 ]; then
            multiplas_globals
        else
            var=`echo $VAR_1 | awk -F '=' '{print $2}'`
            if [ -z $var ]; then
                echo "$(date +%Y%m%d-%H%M%S.%s):MAIN:Global não informada: [$var]." >> $LOG
                printf '%s\n' "Global não informada: $var"    
            else
                labelGlobal="{{global.$var}}"
                echo "$(date +%Y%m%d-%H%M%S.%s):MAIN:Iniciando processo de busca da global: [$labelGlobal]." >> $LOG
                printf '\n\n%s\n' $(seq -s '-' 134 | tr -d [:digit:])
                printf '%s\n' "BUSCANDO GLOBAL: $labelGlobal"
                printf '%s\n' $(seq -s '-' 134 | tr -d [:digit:])
                find_global
            fi
        fi
    ;;
    "--search-capsule")

        if [ -z $VAR_1 ]; then
            multiplas_capsule
        else
            var=`echo $VAR_1 | awk -F '=' '{print $2}'`
            if [ -z $var ]; then
                echo "$(date +%Y%m%d-%H%M%S.%s):MAIN:Capsula name não informada: [$var]." >> $LOG
                printf '%s\n' "Capsula name não informada: $var"    
            else
                labelCapsule='"capsule":"'$var""
                lbCapsule=$var
                echo "$(date +%Y%m%d-%H%M%S.%s):MAIN:Iniciando processo de busca da capsula: [$lbCapsule]." >> $LOG
                printf '\n\n%s\n' $(seq -s '-' 134 | tr -d [:digit:])
                printf '%s\n' "BUSCANDO CAPSULA: $lbCapsule"
                printf '%s\n' $(seq -s '-' 134 | tr -d [:digit:])
                find_capsule
            fi
        fi
    ;;
    "--search-account")

        if [ -z $VAR_1 ]; then
            multiplas_accounts
        else
            var=`echo $VAR_1 | awk -F '=' '{print $2}'`
            if [ -z $var ]; then
                echo "$(date +%Y%m%d-%H%M%S.%s):MAIN:Account name não informada: [$var]." >> $LOG
                printf '%s\n' "Account name não informada: $var"    
            else
                labelAccount=$var
                echo "$(date +%Y%m%d-%H%M%S.%s):MAIN:Iniciando processo de busca de account: [$labelAccount]." >> $LOG
                printf '\n\n%s\n' $(seq -s '-' 134 | tr -d [:digit:])
                printf '%s\n' "BUSCANDO ACCOUNT: $labelAccount"
                printf '%s\n' $(seq -s '-' 134 | tr -d [:digit:])
                find_account
            fi
        fi
    ;;
    "--deploy")
        echo "$(date +%Y%m%d-%H%M%S.%s):MAIN:Opção escolhida: $FUNC." >> $LOG
        echo "$(date +%Y%m%d-%H%M%S.%s):MAIN:Chamando a função -> deployment()." >> $LOG
        deployment
    ;;
    "--find-text")
        if [ -z $VAR_1 ]; then
            echo "$(date +%Y%m%d-%H%M%S.%s):MAIN:Texto não pode ser vazia: [$VAR_1]." >> $LOG
            echo -e "\033[01;31mTexto não pode ser vazia.\033[00;37m"
            help
            exit 1
        else
            var=`echo $VAR_1 | awk -F '=' '{print $2}'`
            if [ -z $var ]; then
                echo "$(date +%Y%m%d-%H%M%S.%s):MAIN:Texto não informada: [$var]." >> $LOG
                printf '%s\n' "Texto não informada: $var"    
            else
                labelText=$var
                echo "$(date +%Y%m%d-%H%M%S.%s):MAIN:Iniciando processo de busca da global: [$labelGlobal]." >> $LOG
                printf '\n\n%s\n' $(seq -s '-' 134 | tr -d [:digit:])
                printf '%s\n' "BUSCANDO TEXTO: $labelText"
                printf '%s\n' $(seq -s '-' 134 | tr -d [:digit:])
                find_text
            fi
        fi
    ;;
    "--get-config")
        echo "$(date +%Y%m%d-%H%M%S.%s):MAIN:Opção escolhida: $FUNC." >> $LOG
        echo "$(date +%Y%m%d-%H%M%S.%s):MAIN:Chamando a função -> get_config()." >> $LOG
        get_config
    ;;
    "--set-config")
        echo "$(date +%Y%m%d-%H%M%S.%s):MAIN:Opção escolhida: $FUNC." >> $LOG
        echo "$(date +%Y%m%d-%H%M%S.%s):MAIN:Chamando a função -> set_config()." >> $LOG
        if [ -z $VAR_1 ]; then
            realm=${REALM}
            set_config
        else
            var=`echo $VAR_1 | awk -F '=' '{print $2}'`
            if [ -z $var ]; then
                realm=${REALM}
                set_config
            else
                realm=$var
                set_config
            fi
        fi
    ;;
    "--delete-deploy")
        echo "$(date +%Y%m%d-%H%M%S.%s):MAIN:Opção escolhida: $FUNC." >> $LOG
        echo "$(date +%Y%m%d-%H%M%S.%s):MAIN:Chamando a função -> delete_deploy()." >> $LOG
        exit 1
    ;;
    "--help")
        echo "$(date +%Y%m%d-%H%M%S.%s):MAIN:Opção escolhida: $FUNC." >> $LOG
        echo "$(date +%Y%m%d-%H%M%S.%s):MAIN:Chamando a função -> help()." >> $LOG
        help
        exit 1
    ;;
    *)
        echo "$(date +%Y%m%d-%H%M%S.%s):MAIN:Opção escolhida: $FUNC." >> $LOG
        echo "$(date +%Y%m%d-%H%M%S.%s):MAIN:Chamando a função -> help()." >> $LOG
        help
        exit 1
    ;;
esac
