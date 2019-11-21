#!/bin/bash
# Autor: Robson Vaamonde
# Site: www.procedimentosemti.com.br
# Facebook: facebook.com/ProcedimentosEmTI
# Facebook: facebook.com/BoraParaPratica
# YouTube: youtube.com/BoraParaPratica
# Data de criação: 22/11/2018
# Data de atualização: 10/02/2019
# Versão: 0.04
# Testado e homologado para a versão do Ubuntu Server 18.04.x LTS x64
# Kernel >= 4.15.x
#
# Extensible Messaging and Presence Protocol (XMPP) (conhecido anteriormente como Jabber) é um protocolo aberto,
# extensível, baseado em XML, para sistemas de mensagens instantâneas, desenvolvido originalmente para mensagens
# instantâneas e informação de presença formalizado pelo IETF. Softwares com base XMPP são distribuídos em milhares
# de servidores através da internet, e usados por cerca de dez milhões de pessoas em todo mundo, de acordo com a 
# XMPP Standards Foundation.
#
# O Openfire (anteriormente conhecido como Wildfire e Jive Messenger) é um servidor de mensagens instantâneas e de
# conversas em grupo que usa o servidor XMPP escrito em Java e licenciado sob a licença Apache 2.0.
#
# Site Oficial do OpenFire: https://www.igniterealtime.org/projects/openfire/
#
# Vídeo de instalação do GNU/Linux Ubuntu Server 18.04.x LTS: https://www.youtube.com/watch?v=zDdCrqNhIXI
# Vídeo de instalação do LAMP Server no GNU/Linux Ubuntu Server 18.04.x LTS: https://www.youtube.com/watch?v=6EFUu-I3u4s
#
# Variável da Data Inicial para calcular o tempo de execução do script (VARIÁVEL MELHORADA)
# opção do comando date: +%T (Time)
HORAINICIAL=`date +%T`
#
# Variáveis para validar o ambiente, verificando se o usuário e "root", versão do ubuntu e kernel
# opções do comando id: -u (user), opções do comando: lsb_release: -r (release), -s (short), 
# opões do comando uname: -r (kernel release), opções do comando cut: -d (delimiter), -f (fields)
USUARIO=`id -u`
UBUNTU=`lsb_release -rs`
KERNEL=`uname -r | cut -d'.' -f1,2`
#
# Variável do caminho do Log dos Script utilizado nesse curso (VARIÁVEL MELHORADA)
# opções do comando cut: -d (delimiter), -f (fields)
# $0 (variável de ambiente do nome do comando)
LOG="/var/log/$(echo $0 | cut -d'/' -f2)"
#
# Declarando as variaveis para criação da Base de Dados do OpenFire
USER="root"
PASSWORD="pti@2018"
# opção do comando create: create (criação), database (base de dados), base (banco de dados)
# opção do comando create: create (criação), user (usuário), identified by (indentificado por - senha do usuário), password (senha)
# opção do comando grant: grant (permissão), usage (uso em | uso na), *.* (todos os bancos/tabelas), to (para), user (usário)
# identified by (indentificado por - senha do usuário), password (senha)
# opões do comando GRANT: grant (permissão), all (todos privilegios), on (em ou na | banco ou tabela), *.* (todos os bancos/tabelas)
# to (para), user@'%' (usuário @ localhost), identified by (indentificado por - senha do usuário), password (senha)
# opção do comando FLUSH: flush (atualizar), privileges (recarregar as permissões)
DATABASE="CREATE DATABASE openfire;"
USERDATABASE="CREATE USER 'openfire' IDENTIFIED BY 'openfire';"
GRANTDATABASE="GRANT USAGE ON *.* TO 'openfire' IDENTIFIED BY 'openfire';"
GRANTALL="GRANT ALL PRIVILEGES ON openfire.* TO 'openfire';"
FLUSH="FLUSH PRIVILEGES;"
#
# Declarando a variável de download do OpenFire
# OPENFIRE="https://www.igniterealtime.org/downloadServlet?filename=openfire/openfire_4.2.3_all.deb"
  OPENFIRE="https://www.igniterealtime.org/downloads/download-landing.jsp?file=openfire/openfire_4.4.4_all.deb"
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
# Verificando se as dependêncais do OpenFire estão instaladas
# opção do dpkg: -s (status), opção do echo: -e (intepretador de escapes de barra invertida), -n (permite nova linha)
# || (operador lógico OU), 2> (redirecionar de saída de erro STDERR), && = operador lógico AND, { } = agrupa comandos em blocos
# [ ] = testa uma expressão, retornando 0 ou 1, -ne = é diferente (NotEqual)
echo -n "Verificando as dependências, aguarde... "
	for name in mysql-server mysql-common
	do
  		[[ $(dpkg -s $name 2> /dev/null) ]] || { echo -en "\n\nO software: $name precisa ser instalado. \nUse o comando 'apt install $name'\n";deps=1; }
	done
		[[ $deps -ne 1 ]] && echo "Dependências.: OK" || { echo -en "\nInstale as dependências acima e execute novamente este script\n";exit 1; }
		sleep 5
#		
# Script de instalação do OpenFire no GNU/Linux Ubuntu Server 18.04.x
# opção do comando echo: -e (enable interpretation of backslash escapes), \n (new line)
# opção do comando hostname: -I (all IP address)
# opção do comando date: + (format), %d (day), %m (month), %Y (year 1970), %H (hour 24), %M (minute 60)
echo -e "Início do script $0 em: `date +%d/%m/%Y-"("%H:%M")"`\n" &>> $LOG
clear
echo -e "Instalação do OpenFire no GNU/Linux Ubuntu Server 18.04.x\n"
echo -e "Após a instalação do OpenFire acessar a URL: http://`hostname -I | cut -d' ' -f1`:9090/\n"
echo -e "Aguarde, esse processo demora um pouco dependendo do seu Link de Internet..."
sleep 5
echo
#
echo -e "Adicionando o Repositório Universal do Apt, aguarde..."
	#opção do comando: &>> (redirecionar de saída padrão)
	add-apt-repository universe &>> $LOG
echo -e "Repositório adicionado com sucesso!!!, continuando com o script..."
sleep 5
echo
#
echo -e "Atualizando as listas do Apt, aguarde..."
	#opção do comando: &>> (redirecionar de saída padrão)
	apt update &>> $LOG
echo -e "Listas atualizadas com sucesso!!!, continuando com o script..."
sleep 5
echo
#
echo -e "Atualizando o sistema, aguarde..."
	#opção do comando: &>> (redirecionar de saída padrão)
	#opção do comando apt: -y (yes)
	apt -y upgrade &>> $LOG
echo -e "Sistema atualizado com sucesso!!!, continuando com o script..."
sleep 5
echo
#
echo -e "Removendo software desnecessários, aguarde..."
	#opção do comando: &>> (redirecionar de saída padrão)
	#opção do comando apt: -y (yes)
	apt -y autoremove &>> $LOG
echo -e "Software removidos com sucesso!!!, continuando com o script..."
sleep 5
echo
#
echo -e "Instalando o OpenFire, aguarde..."
echo
#
echo -e "Instalando as dependências do OpenFire, aguarde..."
	#opção do comando: &>> (redirecionar de saída padrão)
	#opção do comando apt: -y (yes)
	apt -y install openjdk-8-jdk openjdk-8-jre &>> $LOG
echo -e "Instalação das dependências feita com sucesso!!!, continuando com o script..."
sleep 5
echo
#
echo -e "Verificando a versão do Java, aguarde..."
	#opção do comando: &>> (redirecionar de saída padrão)
	java -version &>> $LOG
echo -e "Versão verificada com sucesso!!!, continuando com o script..."
sleep 5
echo
#				 
echo -e "Criando o Banco de Dados do OpenFire, aguarde..."
	#opção do comando: &>> (redirecionar de saída padrão)
	#opção do comando mysql: -u (user), -p (password), -e (execute)
	mysql -u $USER -p$PASSWORD -e "$DATABASE" mysql &>> $LOG
	mysql -u $USER -p$PASSWORD -e "$USERDATABASE" mysql &>> $LOG
	mysql -u $USER -p$PASSWORD -e "$GRANTDATABASE" mysql &>> $LOG
	mysql -u $USER -p$PASSWORD -e "$GRANTALL" mysql &>> $LOG
	mysql -u $USER -p$PASSWORD -e "$FLUSH" mysql &>> $LOG	
echo -e "Banco de Dados criado com sucesso!!!, continuando com o script..."
sleep 5
echo
#
echo -e "Baixando o OpenFire do site oficial, aguarde..."
	#opção do comando: &>> (redirecionar de saída padrão)
	#opção do comando wget: -O (output document file)
	wget $OPENFIRE -O openfire.deb &>> $LOG
echo -e "OpenFire baixado com sucesso!!!, continuando com o script..."
sleep 5
echo
#
echo -e "Instalando o OpenFire, aguarde..."
	#opção do comando: &>> (redirecionar de saída padrão)
	#opção do comando dpkg: -i (install)
	dpkg -i openfire.deb &>> $LOG
echo -e "OpenFire instalado com sucesso!!!, continuando com o script..."
sleep 5
echo
#
echo -e "Verificando a porta de conexão do OpenFire, aguarde..."
	#opção do comando netstat: -a (all), -n (numeric)
	netstat -an | grep 9090
echo -e "Porta de conexão verificada com sucesso!!!, continuando com o script..."
sleep 5
echo
#
echo -e "Instalação do OpenFire feita com Sucesso!!!"
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
