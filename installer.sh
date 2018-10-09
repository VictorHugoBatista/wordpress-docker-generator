#!/bin/bash
bin_path='/usr/bin'
script_name='wp-gen-env'
script_file="$bin_path/$script_name"
compose_sample='docker-compose-sample.yml'
compose_file="$bin_path/$compose_sample"

# Cores utilizados no script.
RED="\e[91m"
GREEN="\e[92m"
BLUE="\e[94m"
RESET="\e[0m"

if [ -e $script_file ]; then
    echo 'Operações disponíveis:'
    echo -e "${GREEN}1 - Atualizar$RESET"
    echo -e "${RED}2 - Remover$RESET"
    echo

    # Pede confirmação sobre a estrutura à ser criada
    opcao=''
    while [ "$opcao" = '' ] || [ "$opcao" != '1' ] && [ "$opcao" != '2' ]; do
        read -p 'Entre com uma das opções para prosseguir: ' opcao
    done

    if [ "$opcao" = '1' ]; then
        echo "O arquivo $script_name será atualizado no diretório $bin_path"
    else
        echo "O arquivo $script_name será removido do diretório $bin_path"
    fi
else
    echo "O arquivo $script_name será adicionado ao diretório $bin_path"
fi

# Pede confirmação sobre a estrutura à ser criada
continue_process=''
while [ "$continue_process" = '' ] || [ "$continue_process" != 's' ] && [ "$continue_process" != 'n' ]; do
    echo -e "Digite ${GREEN}s$RESET para prosseguir ou ${RED}n$RESET para cancelar: "
    read continue_process
done
# Para a execução caso a opção selecionada foi 'n'
if [ "$continue_process" = 'n' ]; then
    echo 'A operação foi cancelada!'
    exit 0
fi

if [ -e $script_file ]; then
    if [ "$opcao" = '1' ]; then
        sudo cp -rf $compose_sample $bin_path
        sudo cp -rf $script_name.sh $script_file
        sudo chmod +x $script_file
        echo "Comando $script_name atualizado com sucesso!"
    else
        sudo rm $compose_file
        sudo rm $script_file
        echo "Comando $script_name desinstalado com sucesso!"
    fi
else
    sudo cp $compose_sample $bin_path
    sudo cp $script_name.sh $script_file
    sudo chmod +x $script_file
    echo "Comando $script_name instalado com sucesso!"
fi

