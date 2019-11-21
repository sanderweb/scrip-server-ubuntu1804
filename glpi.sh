#!/bin/bash
# Autor: Robson Vaamonde
# Site: www.procedimentosemti.com.br
# Facebook: facebook.com/ProcedimentosEmTI
# Facebook: facebook.com/BoraParaPratica
# YouTube: youtube.com/BoraParaPratica
# Data de criação: 08/02/2019
# Data de atualização: 28/02/2019
# Versão: 0.02
# Testado e homologado para a versão do Ubuntu Server 18.04.x LTS x64
# Kernel >= 4.15.x
# Testado e homologado para a versão do GLPI-9.4.x
#
# GLPI (sigla em francês: Gestionnaire Libre de Parc Informatique, ou "Free IT Equipment Manager" em inglês) é um sistema
# gratuito de Gerenciamento de Ativos de TI, sistema de rastreamento de problemas e central de atendimento. Este software
# de código aberto é escrito em PHP e distribuído sob a Licença Pública Geral GNU.
#
# O GLPI é um aplicativo baseado na Web que ajuda as empresas a gerenciar seu sistema de informações. A solução é capaz de 
# criar um inventário de todos os ativos da organização e gerenciar tarefas administrativas e financeiras. As funcionalidades
# dos sistemas auxiliam os administradores de TI a criar um banco de dados de recursos técnicos, além de um gerenciamento e 
# histórico de ações de manutenções. Os usuários podem declarar incidentes ou solicitações (com base no ativo ou não) graças
# ao recurso de Helpdesk.
#
# Site oficial: https://glpi-project.org/pt-br/
#
# Vídeo de instalação do GNU/Linux Ubuntu Server 18.04.x LTS: https://www.youtube.com/watch?v=zDdCrqNhIXI
# Vídeo de atualização do Sistema: https://www.youtube.com/watch?v=esnu8TAepHU
# Vídeo de configuração da Placa de Rede: https://www.youtube.com/watch?v=zSUd4k108Zk
# Vídeo de configuração do Hostname e Hosts: https://www.youtube.com/watch?v=J7eyb5ynjZA
# Vídeo de instalação do LAMP Server no Ubuntu Server 18.04.x LTS: https://www.youtube.com/watch?v=6EFUu-I3
#
# Variável da Data Inicial para calcular o tempo de execução do script (VARIÁVEL MELHORADA)
# opção do comando date: +%T (Time)
HORAINICIAL=$(date +%T)
#
# Variáveis para validar o ambiente, verificando se o usuário e "root", versão do ubuntu e kernel
# opções do comando id: -u (user)
# opções do comando: lsb_release: -r (release), -s (short), 
# opões do comando uname: -r (kernel release)
# opções do comando cut: -d (delimiter), -f (fields)
# opção do shell script: piper | = Conecta a saída padrão com a entrada padrão de outro comando
# opção do shell script: acento crase ` ` = Executa comandos numa subshell, retornando o resultado
# opção do shell script: aspas simples ' ' = Protege uma string completamente (nenhum caractere é especial)
# opção do shell script: aspas duplas " " = Protege uma string, mas reconhece $, \ e ` como especiais
# opção do shell script: $() = Executa comandos numa subshell, retornando o resultado
USUARIO=$(id -u)
UBUNTU=$(lsb_release -rs)
KERNEL=$(uname -r | cut -d'.' -f1,2)
#
# Variável do caminho do Log dos Script utilizado nesse curso (VARIÁVEL MELHORADA)
# opções do comando cut: -d (delimiter), -f (fields)
# $0 (variável de ambiente do nome do comando)
LOG="/var/log/$(echo $0 | cut -d'/' -f2)"
#
# opção do comando create: create (criação), database (base de dados), base (banco de dados)
# opção do comando create: create (criação), user (usuário), identified by (indentificado por - senha do usuário), password (senha)
# opção do comando grant: grant (permissão), usage (uso em | uso na), *.* (todos os bancos/tabelas), to (para), user (usuário)
# identified by (indentificado por - senha do usuário), password (senha)
# opões do comando GRANT: grant (permissão), all (todos privilegios), on (em ou na | banco ou tabela), *.* (todos os bancos/tabelas)
# to (para), user@'%' (usuário @ localhost), identified by (indentificado por - senha do usuário), password (senha)
# opção do comando FLUSH: flush (atualizar), privileges (recarregar as permissões)
USER="root"
PASSWORD="pti@2018"
DATABASE="CREATE DATABASE glpi;"
USERDATABASE="CREATE USER 'glpi' IDENTIFIED BY 'glpi';"
GRANTDATABASE="GRANT USAGE ON *.* TO 'glpi' IDENTIFIED BY 'glpi';"
GRANTALL="GRANT ALL PRIVILEGES ON glpi.* TO 'glpi' IDENTIFIED BY 'glpi';"
FLUSH="FLUSH PRIVILEGES;"
#
# Variáveis de instalação do GLPI
RELEASE="https://github.com/glpi-project/glpi/releases/download/9.4.0/glpi-9.4.0.tgz"
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
# Verificando se as dependêncais do GLPI estão instaladas
# opção do dpkg: -s (status), opção do echo: -e (intepretador de escapes de barra invertida), -n (permite nova linha)
# || (operador lógico OU), 2> (redirecionar de saída de erro STDERR), && = operador lógico AND, { } = agrupa comandos em blocos
# [ ] = testa uma expressão, retornando 0 ou 1, -ne = é diferente (NotEqual)
echo -n "Verificando as dependências, aguarde... "
	for name in mysql-server mysql-common apache2
	do
  		[[ $(dpkg -s $name 2> /dev/null) ]] || { echo -en "\n\nO software: $name precisa ser instalado. \nUse o comando 'apt install $name'\n";deps=1; }
	done
		[[ $deps -ne 1 ]] && echo "Dependências.: OK" || { echo -en "\nInstale as dependências acima e execute novamente este script\n";exit 1; }
		sleep 5
#
# Script de instalação do GLPI no GNU/Linux Ubuntu Server 18.04.x
# opção do comando echo: -e (enable interpretation of backslash escapes), \n (new line)
# opção do comando hostname: -I (all IP address)
# opção do comando date: + (format), %d (day), %m (month), %Y (year 1970), %H (hour 24), %M (minute 60)
echo -e "Início do script $0 em: `date +%d/%m/%Y-"("%H:%M")"`\n" &>> $LOG
#
echo -e "Instalação do GLPI no GNU/Linux Ubuntu Server 18.04.x\n"
echo -e "Após a instalação do GLPI acessar a URL: http://`hostname -I`/glpi/\n"
echo -e "Aguarde, esse processo demora um pouco dependendo do seu Link de Internet...\n"
sleep 5
#
echo -e "Adicionando o Repositório Universal do Apt, aguarde..."
	# opção do comando: &>> (redirecionar a saída padrão)
	add-apt-repository universe &>> $LOG
echo -e "Repositório adicionado com sucesso!!!, continuando com o script..."
sleep 5
echo
#
echo -e "Adicionando o Repositório Multiversão do Apt, aguarde..."
	# opção do comando: &>> (redirecionar a saída padrão)
	add-apt-repository multiverse &>> $LOG
echo -e "Repositório adicionado com sucesso!!!, continuando com o script..."
sleep 5
echo
#
echo -e "Atualizando as listas do Apt, aguarde..."
	#opção do comando: &>> (redirecionar a saída padrão)
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
echo -e "Software removidos com sucesso!!!, continuando com o script..."
sleep 5
clear
#
echo -e "Instalando o GLPI, aguarde...\n"
#
echo -e "Instalando as dependências do GLPI, aguarde..."
	# opção do comando: &>> (redirecionar a saída padrão)
	# opção do comando apt: -y (yes), \ (faz a função de quebra de pagina no comando apt)
	apt -y install php-curl php-gd php-intl php-pear php-imagick php-imap php-memcache php-pspell php-mysql \
	php-recode php-tidy php-xmlrpc php-xsl php-mbstring php-gettext php-ldap php-cas php-apcu libapache2-mod-php \
	php-json php-iconv php-xml &>> $LOG
echo -e "Source List criado com sucesso!!!, continuando com o script..."
sleep 5
echo
#
echo -e "Instalando o GLPI e criando a Base de Dados, aguarde..."
	# opção do comando: &>> (redirecionar a saida padrão)
	# opção do comando tar: -j (bzip2), -x (extract), -v (verbose), -f (file)
	# opção do comando mv: -v (verbose)
	# opção do comando chown: -R (recursive), -v (verbose), www-data.www-data (user and group)
	# opção do comando chmod: -R (recursive), -v (verbose), 755 (User=RWX, Group=R-X, Other=R-X)
	# opção do comando mysql: -u (user), -p (password), -e (execute)
	wget $RELEASE &>> $LOG
	GLPIFILE=`echo glpi*.*.*`
	tar -zxvf $GLPIFILE &>> $LOG
	mv -v glpi/ /var/www/html/glpi/ &>> $LOG
	chown -Rv www-data:www-data /var/www/html/glpi/ &>> $LOG
	chmod -Rv 755 /var/www/html/glpi/ &>> $LOG
	mysql -u $USER -p$PASSWORD -e "$DATABASE" mysql &>> $LOG
	mysql -u $USER -p$PASSWORD -e "$USERDATABASE" mysql &>> $LOG
	mysql -u $USER -p$PASSWORD -e "$GRANTDATABASE" mysql &>> $LOG
	mysql -u $USER -p$PASSWORD -e "$GRANTALL" mysql &>> $LOG
	mysql -u $USER -p$PASSWORD -e "$FLUSH" mysql &>> $LOG
echo -e "GLPI instalado com sucesso!!!, continuando com o script..."
sleep 5
echo
#
echo -e "Habilitando os recursos do Apache2 para suportar o GLPI, aguarde..."
	# opção do comando: &>> (redirecionar a saída padrão)
	# opção do comando cp: -v (verbose)
	# opção do comando phpenmod: (habilitar módulos do PHP)
	# opção do comando a2enconf: (habilitar arquivo de configuração de site do Apache2)
	# opção do comando systemctl: restart (reinicializar o serviço)
	cp -v conf/glpi.conf /etc/apache2/conf-available/
	cp -v conf/glpi-cron /etc/cron.d/ 
	phpenmod apcu
	a2enconf glpi
	systemctl restart apache2 &>> $LOG
echo -e "Recursos habilitados com sucesso!!!, continuando com o script..."
sleep 5
echo
#
echo -e "Instalação do GLPI feita com Sucesso!!!."
	# script para calcular o tempo gasto (SCRIPT MELHORADO, CORRIGIDO FALHA DE HORA:MINUTO:SEGUNDOS)
	# opção do comando date: +%T (Time)
	HORAFINAL=$(date +%T)
	# opção do comando date: -u (utc), -d (date), +%s (second since 1970)
	HORAINICIAL01=$(date -u -d "$HORAINICIAL" +"%s")
	HORAFINAL01=$(date -u -d "$HORAFINAL" +"%s")
	# opção do comando date: -u (utc), -d (date), 0 (string command), sec (force second), +%H (hour), %M (minute), %S (second), 
	TEMPO=$(date -u -d "0 $HORAFINAL01 sec - $HORAINICIAL01 sec" +"%H:%M:%S")
	# $0 (variável de ambiente do nome do comando)
	echo -e "Tempo gasto para execução do script $0: $TEMPO"
echo -e "Pressione <Enter> para concluir o processo."
# opção do comando date: + (format), %d (day), %m (month), %Y (year 1970), %H (hour 24), %M (minute 60)
echo -e "Fim do script $0 em: `date +%d/%m/%Y-"("%H:%M")"`\n" &>> $LOG
read
exit 1
