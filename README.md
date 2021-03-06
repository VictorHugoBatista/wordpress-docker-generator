# wordpress-docker-generator
Gera a estrutua de containeres PHP, Apache e MySQL com docker-compose, adicionando uma instalação Wordpress vazia na raíz do ambiente.

## Requisitos
 * Sistema que permita a execução de [shell scripts](https://pt.wikipedia.org/wiki/Shell_script)
 * [Docker](https://www.docker.com/)
 * [Docker Compose](https://docs.docker.com/compose/)

## Instalação
 * Dê permissão de execução ao arquivo installer.sh;
 ```
 chmod +x installer.sh
 ```
 * Execute o arquivo por meio do comando **./installer.sh**;
 * O script irá instalar o comando gerador de ambientes após uma mensagem de confirmação;
 * Após isso o comando **wp-gen-env** estará disponível. O comando pode ser executado sem parãmetros para a exibição da ajuda.
 
## Atualização / desinstalação
* Com o comando já disponível no sistema, execute o arquivo installer.sh por meio de **./installer.sh**;
* Selecione a opção **1** para atualizar o script com a versão no diretório atual ou a opção **2** para remover o script do sistema.

## Documentação
 * Parâmetros obrigatórios:
    * Título do projeto, define o título do diretório raíz e o nome dos containeres;
    * Virtualhost apontando para o ambiente criado;
    * Nome do banco MySQL gerado automaticamente;
    * Senha do usuário root do MySQL.
 * Parâmetros opcionais:
    * Versão do PHP utilizada no ambiente. Padrão: **latest** (ver https://hub.docker.com/r/webgriffe/php-apache-base/tags/);
    * Raíz do Apache: Diretório à partir de **/var/html/www** (diretório **public** na raíz da estrutura de diretórios criada).
 * Exemplo:
    * **wp-gen-env projeto-teste test.dev base-teste root 5.6 public**
 * Ao executar o comando exbido acima, a seguinte estrutura será criada à partir do seu diretório atual (**você ainda pode prosseguir ou cancelar antes que a estrutura seja gerada**):
  ```
  - projeto-teste
  |- public (raíz do apache do docker, com uma instalação wordpress limpa incluída)
  |- mysql (diretório de armazenamendo dos dados do mysql do docker)
  |- docker-compose.yml (arquivo já com as configurações iniciais)
  ```

## WP-CLI
Os comandos do WP-CLI são disponibilizados por meio de um container de imagem **tatemz/wp-cli**.
O comando abaixo deve ser executado em qualquer subdiretório do ambiente:
```
docker-compose run --rm wp-cli
```
Você também pode criar um alias para encurtar o comando. Exemplo:
```
alias wp="docker-compose run --rm wp-cli"
```
Dessa forma você poderá efetuar comandos com **wp plugin install**, da mesma forma que faria fora do docker.

## Dicas importantes
 * O MySQL deve ser referenciado pelo nome do container MySQL gerado automaticamente (definido pelo título do projeto seguido de **-db**) e não por localhost.
 * Os containeres podem ser parados executando o comando **docker-compose stop**, reiniciados com o comando **docker-compose restart** e inicializados com o comando **docker-compose up -d** na raíz da estrutura de diretórios gerada.
 * É possível verificar os containeres executando com o comando **docker ps**, verificar todos os containeres criados com **docker ps -a** e parar todos os containeres com **docker stop $(docker ps -q)**.
