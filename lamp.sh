#!/bin/bash
# Autor: Robson Vaamonde
# Site: www.procedimentosemti.com.br
# Facebook: facebook.com/ProcedimentosEmTI
# Facebook: facebook.com/BoraParaPratica
# YouTube: youtube.com/BoraParaPratica
# Data de criação: 04/11/2018
# Data de atualização: 10/02/2019
# Versão: 0.06
# Testado e homologado para a versão do Ubuntu Server 18.04.x LTS x64
# Kernel >= 4.15.x
#
# APACHE-2.4 (Apache HTTP Server) -Servidor de Hospedagem de Páginas Web: https://www.apache.org/
# MYSQL-5.7 (SGBD) - Sistemas de Gerenciamento de Banco de Dados: https://www.mysql.com/
# PHP-7.2 (Personal Home Page - PHP: Hypertext Preprocessor) - Linguagem de Programação Dinâmica para Web: http://www.php.net/
# PERL-5.26 - Linguagem de programação multiplataforma: https://www.perl.org/
# PYTHON-2.7 - Linguagem de programação de alto nível: https://www.python.org/
# PHPMYADMIN-4.6 - Aplicativo desenvolvido em PHP para administração do MySQL pela Internet: https://www.phpmyadmin.net/
#
# Debconf - Sistema de configuração de pacotes Debian
# Site: http://manpages.ubuntu.com/manpages/bionic/man7/debconf.7.html
# Debconf-Set-Selections - insere novos valores no banco de dados debconf
# Site: http://manpages.ubuntu.com/manpages/bionic/man1/debconf-set-selections.1.html
#
# Opção: lamp-server^ Recurso existente no GNU/Ubuntu Server para facilitar a instalação do Servidor LAMP
# A opção de circunflexo no final do comando e obrigatório, considerado um meta-caracter de filtragem para
# a instalação correta de todos os serviços do LAMP.
# Recurso faz parte do software Tasksel: https://help.ubuntu.com/community/Tasksel
#
# O módulo do PHP Mcrypt na versão 7.2 está descontinuado, para fazer sua instalação e recomendado utilizar
# o comando o Pecl e adicionar o repositório pecl.php.net, a instalação e baseada em compilação do módulo.
#
# Observação: Nesse script está sendo feito a instalação do Oracle MySQL, hoje os desenvolvedores estão migrando
# para o MariaDB, nesse script o mesmo deve ser reconfigurado para instalar e configurar o MariaDB no Ubuntu.
# sudo apt update && sudo apt install mariadb-server mariadb-client mariadb-common
#
# Vídeo de instalação do GNU/Linux Ubuntu Server 18.04.x LTS: https://www.youtube.com/watch?v=zDdCrqNhIXI
#
# Variável da Data Inicial para calcular o tempo de execução do script (VARIÁVEL MELHORADA)
# opção do comando date: +%T (Time)
HORAINICIAL=`date +%T`
#
# Variáveis para validar o ambiente, verificando se o usuário e "root", versão do ubuntu e kernel
# opções do comando id: -u (user), opções do comando: lsb_release: -r (release), -s (short), 
# opções do comando uname: -r (kernel release), opções do comando cut: -d (delimiter), -f (fields)
# opção do caracter: | (piper) Conecta a saída padrão com a entrada padrão de outro comando
# opção do shell script: acento crase ` ` = Executa comandos numa subshell, retornando o resultado
# opção do shell script: aspas simples ' ' = Protege uma string completamente (nenhum caractere é especial)
# opção do shell script: aspas duplas " " = Protege uma string, mas reconhece $, \ e ` como especiais
USUARIO=`id -u`
UBUNTU=`lsb_release -rs`
KERNEL=`uname -r | cut -d'.' -f1,2`
#
# Variável do caminho do Log dos Script utilizado nesse curso (VARIÁVEL MELHORADA)
# opções do comando cut: -d (delimiter), -f (fields)
# $0 (variável de ambiente do nome do comando)
LOG="/var/log/$(echo $0 | cut -d'/' -f2)"
#
# Variáveis de configuração do MySQL e liberação de conexão remota para o usuário Root
USER="root"
PASSWORD="pti@2018"
AGAIN=$PASSWORD
# opões do comando GRANT: grant (permissão), all (todos privilegios), on (em ou na | banco ou tabela), *.* (todos os bancos/tabelas)
# to (para), user@'%' (usuário @ localhost), identified by (indentificado por - senha do usuário)
# opção do comando FLUSH: privileges (recarregar as permissões)
GRANTALL="GRANT ALL ON *.* TO $USER@'%' IDENTIFIED BY '$PASSWORD';"
FLUSH="FLUSH PRIVILEGES;"
#
# Variáveis de configuração do PhpMyAdmin
ADMINUSER=$USER
ADMIN_PASS=$PASSWORD
APP_PASSWORD=$PASSWORD
APP_PASS=$PASSWORD
WEBSERVER="apache2"
#
# Exportando o recurso de Noninteractive do Debconf para não solicitar telas de configuração
export DEBIAN_FRONTEND="noninteractive"
#
# Verificando se o usuário e Root, Distribuição e >=18.04 e o Kernel >=4.15 <IF MELHORADO)
# [ ] = teste de expressão, && = operador lógico AND, == comparação de string, exit 1 = A maioria dos erros comuns na execução
clear
if [ "$USUARIO" == "0" ] && [ "$UBUNTU" == "18.04" ] && [ "$KERNEL" == "4.15" ]
	then
		echo -e "O usuário e Root, continuando com o script..."
		echo -e "Distribuição e >=18.04.x, continuando com o script..."
		echo -e "Kernel e >= 4.15, continuando com o script..."
		sleep 5
	else
		echo -e "Usuário não e Root ($USUARIO) ou Distribuição não e >=18.04.x ($UBUNTU) ou Kernel não e >=4.15 ($KERNEL)"
		echo -e "Caso você não tenha executado o script com o comando: sudo -i"
		echo -e "Execute novamente o script para verificar o ambiente."
		exit 1
fi
#
# Script de instalação do LAMP-Server no GNU/Linux Ubuntu Server 18.04.x
# opção do comando echo: -e (enable) habilita interpretador, \n = (new line)
# opção do comando hostname: -I (all IP address)
# opção do comando sleep: 5 (seconds)
# opção do comando date: + (format), %d (day), %m (month), %Y (year 1970), %H (hour 24), %M (minute 60)
echo -e "Início do script $0 em: `date +%d/%m/%Y-"("%H:%M")"`\n" &>> $LOG
clear
#
clear
echo -e "Instalação do LAMP-SERVER no GNU/Linux Ubuntu Server 18.04.x\n"
echo -e "APACHE (Apache HTTP Server) - Servidor de Hospedagem de Páginas Web - Porta 80/443"
echo -e "Após a instalação do Apache2 acessar a URL: http://`hostname -I`/\n"
echo -e "MYSQL (SGBD) - Sistemas de Gerenciamento de Banco de Dados - Porta 3306\n"
echo -e "PHP (Personal Home Page - PHP: Hypertext Preprocessor) - Linguagem de Programação Dinâmica para Web\n"
echo -e "PERL - Linguagem de programação multi-plataforma\n"
echo -e "PYTHON - Linguagem de programação de alto nível\n"
echo -e "PhpMyAdmin - Aplicativo desenvolvido em PHP para administração do MySQL pela Internet"
echo -e "Após a instalação do PhpMyAdmin acessar a URL: http://`hostname -I`/phpmyadmin\n"
echo -e "Aguarde, esse processo demora um pouco dependendo do seu Link de Internet..."
sleep 5
echo
#
echo -e "Adicionando o Repositório Universal do Apt, aguarde..."
	# opção do comando: &>> (redirecionar a saída padrão)
	add-apt-repository universe &>> $LOG
echo -e "Repositório adicionado com sucesso!!!, continuando com o script..."
sleep 5
echo
#
echo -e "Atualizando as listas do Apt, aguarde..."
	# opção do comando: &>> (redirecionar a saída padrão)
	apt update &>> $LOG
echo -e "Listas atualizadas com sucesso!!!, continuando com o script..."
sleep 5
echo
#
echo -e "Atualizando o sistema, aguarde..."
	# opção do comando: &>> (redirecionar a saída padrão)
	# opção do comando apt: -y (yes)
	apt -y upgrade &>> $LOG
echo -e "Sistema atualizado com sucesso!!!, continuando com o script..."
sleep 5
echo
#
echo -e "Removendo software desnecessários, aguarde..."
	# opção do comando: &>> (redirecionar a saída padrão)
	# opção do comando apt: -y (yes)
	apt -y autoremove &>> $LOG
echo -e "Software removidos com Sucesso!!!, continuando com o script..."
sleep 5
echo
#
echo -e "Instalando o LAMP-SERVER, aguarde..."
echo
#
echo -e "Configurando as variáveis do Debconf do MySQL para o Apt, aguarde..."
	# opção do comando: &>> (redirecionar a saída padrão)
	# opção do comando | (piper): (Conecta a saída padrão com a entrada padrão de outro comando)
	echo "mysql-server-5.7 mysql-server/root_password password $PASSWORD" |  debconf-set-selections
	echo "mysql-server-5.7 mysql-server/root_password_again password $AGAIN" |  debconf-set-selections
	debconf-show mysql-server-5.7 &>> $LOG
echo -e "Variáveis configuradas com sucesso!!!, continuando com o script..."
sleep 5
echo
#
echo -e "Instalando o LAMP-SERVER, aguarde..."
	# opção do comando: &>> (redirecionar a saída padrão)
	# opção do comando apt: -y (yes)
	# opção do comando ^ (circunflexo): (expressão regular - Casa o começo da linha)
	apt -y install lamp-server^ perl python &>> $LOG
echo -e "Instalação do LAMP-SERVER feito com sucesso!!!, continuando com o script..."
sleep 5
echo
#
echo -e "Instalando o PhpMyAdmin, aguarde..."
echo
#
echo -e "Configurando as variáveis do Debconf do PhpMyAdmin para o Apt, aguarde..."
	# opção do comando: &>> (redirecionar a saída padrão)
	# opção do comando | (piper): (Conecta a saída padrão com a entrada padrão de outro comando)
	echo "phpmyadmin phpmyadmin/internal/skip-preseed boolean true" |  debconf-set-selections
	echo "phpmyadmin phpmyadmin/dbconfig-install boolean true" |  debconf-set-selections
	echo "phpmyadmin phpmyadmin/app-password-confirm password $APP_PASSWORD" |  debconf-set-selections
	echo "phpmyadmin phpmyadmin/reconfigure-webserver multiselect $WEBSERVER" |  debconf-set-selections
	echo "phpmyadmin phpmyadmin/mysql/admin-user string $ADMINUSER" |  debconf-set-selections
	echo "phpmyadmin phpmyadmin/mysql/admin-pass password $ADMIN_PASS" |  debconf-set-selections
	echo "phpmyadmin phpmyadmin/mysql/app-pass password $APP_PASS" |  debconf-set-selections
	debconf-show phpmyadmin &>> $LOG
echo -e "Variáveis configuradas com sucesso!!!, continuando com o script..."
sleep 5
echo
#
echo -e "Instalando o PhpMyAdmin, aguarde..."
	# opção do comando: &>> (redirecionar a saída padrão)
	# opção do comando apt: -y (yes)
	apt -y install phpmyadmin php-mbstring php-gettext php-dev libmcrypt-dev php-pear &>> $LOG
echo -e "Instalação do PhpMyAdmin feita com sucesso!!!, continuando com o script..."
sleep 5
echo
#				 
echo -e "Atualizando as dependências do PHP para o PhpMyAdmin, aguarde..."
	# opção do comando: &>> (redirecionar a saída padrão)
	# opção do comando echo: | = (faz a função de Enter)
	# opção do comando cp: -v (verbose)
	pecl channel-update pecl.php.net &>> $LOG
	echo | pecl install mcrypt-1.0.1 &>> $LOG
	cp -v conf/mcrypt.ini /etc/php/7.2/mods-available/ &>> $LOG
	phpenmod mcrypt &>> $LOG
	phpenmod mbstring &>> $LOG
echo -e "Atualização das dependêncais feita com sucesso!!!, continuando com o script..."
sleep 5
echo
#
echo -e "Criando o arquivo de teste do PHP phpinfo.php, aguarde..."
	# opção do comando: > (redirecionar a saída padrão)
	# opção do comando chown: -v (verbose)
	touch /var/www/html/phpinfo.php
	echo -e "<?php phpinfo(); ?>" > /var/www/html/phpinfo.php
	chown -v www-data.www-data /var/www/html/phpinfo.php &>> $LOG
echo -e "Arquivo criado com sucesso!!!, continuando com o script..."
sleep 5
echo
#
echo -e "Instalação do LAMP-Server e PhpMyAdmin feito com sucesso!!! Pressione <Enter> para continuar."
read
sleep 3
clear
#
echo -e "Atualizando e editando o arquivo de configuração do Apache2, aguarde..."
	# opção do comando: &>> (redirecionar a saída padrão)
	# opção do comando cp: -v (verbose)
	# opção do comando sleep: 3 (seconds)
	cp -v /etc/apache2/apache2.conf /etc/apache2/apache2.conf.old &>> $LOG
	cp -v conf/apache2.conf /etc/apache2/apache2.conf &>> $LOG
	echo -e "Pressione <Enter> para editar o arquivo: apache2.conf"
		read
		sleep 3
	vim /etc/apache2/apache2.conf
echo -e "Arquivo atualizado com sucesso!!!, continuando com o script..."
sleep 5
echo
#
echo -e "Atualizando e editando o arquivo de configuração do PHP, aguarde..."
	# opção do comando: &>> (redirecionar a saída padrão)
	# opção do comando cp: -v (verbose)
	# opção do comando sleep: 3 (seconds)
	cp -v /etc/php/7.2/apache2/php.ini /etc/php/7.2/apache2/php.ini.old &>> $LOG
	cp -v conf/php.ini /etc/php/7.2/apache2/php.ini &>> $LOG
	echo -e "Pressione <Enter> para editar o arquivo: php.ini"
		read
		sleep 3
	vim /etc/php/7.2/apache2/php.ini
echo -e "Arquivo atualizado com sucesso!!!, continuando com o script..."
sleep 5
echo
#
echo -e "Reinicializando o serviço do Apache2, aguarde..."
	sudo service apache2 restart
echo -e "Serviço reinicializado com sucesso!!!, continuando com o script..."
sleep 5
echo
#
echo -e "Permitindo o Root do MySQL se autenticar remotamente, aguarde..."
	# opção do comando: &>> (redirecionar a saída padrão)
	# opção do comando mysql: -u (user), -p (password) -e (execute)
	mysql -u $USER -p$PASSWORD -e "$GRANTALL" mysql &>> $LOG
	mysql -u $USER -p$PASSWORD -e "$FLUSH" mysql &>> $LOG
echo -e "Permissão alterada com sucesso!!!, continuando com o script..."
sleep 5
echo
#
echo -e "Atualizando e editando o arquivo de configuração do MySQL, aguarde..."
	# opção do comando: &>> (redirecionar a saída padrão)
	# opção do comando cp: -v (verbose)
	# opção do comando sleep: 3 (seconds)
	cp -v /etc/mysql/mysql.conf.d/mysqld.cnf /etc/mysql/mysql.conf.d/mysqld.cnf.old &>> $LOG
	cp -v conf/mysqld.cnf /etc/mysql/mysql.conf.d/mysqld.cnf &>> $LOG
	echo -e "Pressione <Enter> para editar o arquivo: mysqld.cnf"
		read
		sleep 3
	vim /etc/mysql/mysql.conf.d/mysqld.cnf
echo -e "Arquivo atualizado com sucesso!!!, continuando com o script..."
sleep 5
echo
#
echo -e "Reinicializando os serviços do MySQL, aguarde..."
	sudo service mysql restart
echo -e "Serviço reinicializado com sucesso!!!, continuando com o script..."
sleep 5
echo
#
echo -e "Verificando as portas de Conexão do Apache2 e do MySQL, aguarde..."
	# opção do comando netstat: a (all), n (numeric)
	# opção do comando grep: ' ' (aspas simples) protege uma string, \| (Escape e opção OU)
	netstat -an | grep '80\|3306'
echo -e "Portas verificadas com sucesso!!!, continuando com o script..."
sleep 5
echo
#
echo -e "Instalação do LAMP-SERVER feito com Sucesso!!!"
	# script para calcular o tempo gasto (SCRIPT MELHORADO, CORRIGIDO FALHA DE HORA:MINUTO:SEGUNDOS)
	# opção do comando date: +%T (Time)
	HORAFINAL=`date +%T`
	# opção do comando date: -u (utc), -d (date), +%s (second since 1970)
	HORAINICIAL01=$(date -u -d "$HORAINICIAL" +"%s")
	HORAFINAL01=$(date -u -d "$HORAFINAL" +"%s")
	# opção do comando date: -u (utc), -d (date), 0 (string command), sec (force second), +%H (hour), %M (minute), %S (second), 
	TEMPO=`date -u -d "0 $HORAFINAL01 sec - $HORAINICIAL01 sec" +"%H:%M:%S"`
	# $0 (variável de ambiente do nome do comando)
	echo -e "Tempo gasto para execução do script $0: $TEMPO"
echo -e "Pressione <Enter> para concluir o processo."
# opção do comando date: + (format), %d (day), %m (month), %Y (year 1970), %H (hour 24), %M (minute 60)
echo -e "Fim do script $0 em: `date +%d/%m/%Y-"("%H:%M")"`\n" &>> $LOG
read
exit 1
