#!/bin/bash

RED="\e[91m"
GREEN="\e[92m"
BLUE="\e[94m"
RESET="\e[0m"

if [ $# -lt 4 ]; then
    echo -e "$BLUE"
    echo 'Y8b Y8b Y888P                       888 888 88e'
    echo ' Y8b Y8b Y8P   e88 88e  888,8,  e88 888 888 888D 888,8,  ,e e,   dP"Y  dP"Y'
    echo '  Y8b Y8b Y   d888 888b 888 "  d888 888 888 88"  888 "  d88 88b C88b  C88b'
    echo '   Y8b Y8b    Y888 888P 888    Y888 888 888      888    888   ,  Y88D  Y88D'
    echo '    Y8P Y      "88 88"  888     "88 888 888      888     "YeeP" d,dP  d,dP'
    echo '    __              __                                                          __'
    echo '.--|  |.-----.----.|  |--.-----.----.______.-----.-----.-----.-----.----.---.-.|  |_.-----.----.'
    echo '|  _  ||  _  |  __||    <|  -__|   _|______|  _  |  -__|     |  -__|   _|  _  ||   _|  _  |   _|'
    echo '|_____||_____|____||__|__|_____|__|        |___  |_____|__|__|_____|__| |___._||____|_____|__|'
    echo '                                           |_____|'
    echo -e "$RESET"
    echo 'Parâmetros esperados:'
    echo ' - título do projeto'
    echo ' - virtual host'
    echo ' - nome do banco'
    echo ' - senha do root'
    echo ' - versão do php (opcional)'
    echo ' - raíz do apache à partir de /var/html/www (opcional)'
    echo
    echo "Exemplo de comando completo: ${0##*/} projeto-teste test.dev base-teste root 5.6 public"
    echo 'Repositório do projeto: https://github.com/VictorHugoBatista/wordpress-docker-generator'
    exit 0
fi

project_title=$1
virtual_host=$2
database_name=$3
root_password=$4
php_version=`[ $5 ] && echo $5 || echo 'latest'`
apache_root=`[ $6 ] && echo "$6" || echo ''`

echo -e "$BLUE"
echo 'A seguinte estrutura será criada neste diretório:'
echo " - $project_title"
echo ' |- public (raíz do apache do docker, com uma instalação wordpress limpa incluída)'
echo ' |- mysql (dados armazenados pelo mysql do docker)'
echo ' |- docker-compose.yml (gera os containeres do apache/php e do mysql e os relaciona)'
echo ''
echo 'Os seguintes containeres serão criados:'
echo " - $project_title-web (php/apache)"
echo "   - PHP $php_version"
echo "   - Diretório raíz do apache: /var/www/html/$apache_root"
echo "   - Virtual host: $virtual_host"
echo " - $project_title-db (mysql)"
echo "   - Nome do banco: $database_name"
echo "   - Senha do root: $root_password"
echo -e "$RESET"

# Pede confirmação sobre a estrutura à ser criada
continue_process=''
while [ "$continue_process" = '' ] || [ "$continue_process" != 's' ] && [ "$continue_process" != 'n' ]; do
    echo -e "Digite ${GREEN}s$RESET para prosseguir ou ${RED}n$RESET para cancelar: \c"
    read continue_process
done

# Para a execução caso a opção selecionada foi 'n'
if [ "$continue_process" = 'n' ]; then
    echo -e "${RED}A operação foi cancelada!${RESET}"
    exit 0
fi

# Verifica a existência de um arquivo com o nome
# sugerido para ser o diretório raíz do site. Se
# sim, para o programa com status 1.
if [ -e $project_title ]; then
    echo -e "${RED}Um arquivo/diretório de nome $project_title já existe!${RESET}"
    exit 1
fi

# Gera a estrutura de arquivos e concede permissão
mkdir $project_title
cd $project_title
mkdir public
mkdir mysql
touch docker-compose.yml

# Popula docker-compose e adiciona os dados fornecidos no programa
cat /usr/bin/docker-compose-sample.yml > docker-compose.yml
sed -i "s/NOME-DO-PROJETO/$project_title/g" docker-compose.yml
sed -i "s/VIRTUAL-HOST/$virtual_host/g" docker-compose.yml
sed -i "s/BANCO/$database_name/g" docker-compose.yml
sed -i "s/SENHA-ROOT/$root_password/g" docker-compose.yml
sed -i "s/PHP-VERSION/$php_version/g" docker-compose.yml
sed -i "s/APACHE-ROOT/$apache_root/g" docker-compose.yml

# Baixa a instalação vazia do wordpress automaticamente
cd public
wget https://wordpress.org/latest.tar.gz
tar -xzf latest.tar.gz
mv wordpress/* .
rm -r wordpress
rm latest.tar.gz
cd ..

# Exibe estrutura de arquivos
echo -e "$GREEN"
echo 'Estrutura criada com sucesso:'
echo 'Local: /'
ls -la
echo 'Local: /public'
ls -la public
echo -e "$RESET"

if [ $(docker ps -a -q -f name="$project_title-web") ] || [ $(docker ps -a -q -f name="$project_title-db") ]; then
    echo -e "${RED}Já existem containeres com o mesmo nome da estrutura criada!${RESET}"
    exit 1
fi

# Inicializa ambiente docker
echo -e "${BLUE}Iniciando ambiente...${RESET}"
docker-compose up -d
echo -e "${GREEN}Ambiente inicializado!${RESET}"
echo

sudo chmod -R 777 .

# Gera arquivo wp-config.php e ajusta as permissões do ambiente
echo -e "${BLUE}Gerando arquivo wp-config.php...${RESET}"
sleep 5s
docker-compose run --rm wp-cli core config --dbhost=$project_title-db --dbname=$database_name --dbuser=root --dbpass=$root_password --locale=pt_BR > /dev/null
if [ 0 -eq $? ]; then
    echo -e "${GREEN}Arquivo wp-config.php gerado com sucesso!${RESET}"
else
    echo -e "${RED}Erro na geração do arquivo wp-config.php!${RESET}"
fi
sudo chmod -R 755 .

exit 0
