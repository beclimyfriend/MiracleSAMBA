#! /bin/bash

#April 2016, Joan Chacón Arroyo

#This script configures a samba domain, with PDC

#Tested on Ubuntu 14.04 LTS

#Visit beclimyfriend.blogspot.com for more!!
#Visita beclimyfriend.blogspot.com para más!! 
#Created by Joan Chacón


echo 'Do you want to update your repositories? (Y/N)'

read answer

#Esta parte se puede obviar, simplemente pregutamos por un UPDATE

	if [ "$answer" == "Y" ];

	then


 		echo 'Updating'


 		apt-get update


 		clear

	fi

#Por si los paquetes todavía no están instalados

echo 'Install samba components?(Y/N)'

read answer


	if [ "$answer" == "Y" ];
	
	then


 		echo 'Installing samba components'

		#Lo hacemos en modo silencioso -y

 		apt-get install samba smbclient samba-doc libpam-smbpass -y
	

 		clear

	fi

#Nos creamos un backup del archivo de configuración inicial

echo "Do you want to save your base samba config?(Y/N)(DO IT ONLY IF ITS YOUR FIRST CONFIGURATION)"

read answer


	if [ "$answer" == "Y" ];

	then

 		mv /etc/samba/smb.conf /etc/samba/smb.base.conf

	fi

#Nombre que tendrá nuestro dominio

echo 'Introduce your domain name (exemple.org)'

read domain

#Cambiar el fqdn de nuestra máquina

echo "Do you want to update your fqdn?(recommended)(Y/N)"

read answer


	if [ "$answer" == "Y" ];

	then


 		fqdn= "$(hostname)"."$domain"
	

 		echo "$fqdn" > /etc/hostname

	fi


echo "Let's configure your SAMBA domain!!!"

#Empieza la configuración del global

	echo "[global]" > /etc/samba/smb.conf

	echo "workgroup = $domain" >> /etc/samba/smb.conf

	echo "server role = classic primary domain controller" >> /etc/samba/smb.conf

	echo "security = user" >> /etc/samba/smb.conf

	echo "domain logons = yes" >> /etc/samba/smb.conf

	echo "os level = 34" >> /etc/samba/smb.conf

	echo "preferred master = yes" >> /etc/samba/smb.conf

	echo "wins support = yes" >> /etc/samba/smb.conf

	echo "time server = yes" >> /etc/samba/smb.conf

	echo "passdb backend = tdbsam" >> /etc/samba/smb.conf

	echo "add machine script = sudo /usr/sbin/useradd -N -g machines -c Machine -d /var/lib/samba -s /bin/false %u " >> /etc/samba/smb.conf

	echo "unix password sync = yes" >> /etc/samba/smb.conf

	echo "passwd program = /usr/bin/passwd %u" >> /etc/samba/smb.conf

	echo "passwd chat = *Enter\snew\spassword:* %n\n *Retype\snew\s*\spassword:* %n\n * password\supdated\ssuccessfully*" >> /etc/samba/smb.conf

	echo "pam password change = yes" >> /etc/samba/smb.conf

	echo 'logon path = \\%N\%U\profile' >> /etc/samba/smb.conf

	echo "logon drive = H:" >> /etc/samba/smb.conf

	echo 'logon home = \\%N\%U' >> /etc/samba/smb.conf

	echo "logon script = logon.cmd" >> /etc/samba/smb.conf

	echo "[homes]" >> /etc/samba/smb.conf

	echo "read only = no" >> /etc/samba/smb.conf

	echo "[netlogon]" >> /etc/samba/smb.conf

	echo "comment = $domain Logon Service" >> /etc/samba/smb.conf

	echo "path = /home/samba/netlogon" >> /etc/samba/smb.conf

	echo "guest ok = no" >> /etc/samba/smb.conf

	echo "read only = yes" >> /etc/samba/smb.conf

#Creamos carpeta para el netlogon

mkdir -p /home/samba/netlogon

#Crear el grupo de adaministradores del dominio

echo "Create Domain Admins?(Y/N)recommended if it's your first configuration"

read answer


	if [ "$answer" == "Y" ]; then

	#Mapeamos el grupo Unix en SAMBA

 		net groupmap add ntgroup="Domain Admins" unixgroup=adm rid=512 type=d


	fi

#Crear un usuario administrador

echo "Do you want to create a SMB root user?(Y/N)(If it 's your first time you need to create it)"

read answer

	if [ "$answer" == "Y" ]; then
	
 		echo "Introduce your root samba username"

 		read name


 		adduser $name

 		adduser $name adm

#Creamos el correspondiente usuario SAMBA

 echo "Introduce root samba password"

 smbpasswd -a $name

#Le damos grants de administrador para SAMBA

 net rpc rights grant -U $name "$domain\Domain Admins" SeMachineAccountPrivilege

 net rpc rights grant -U $name "$domain\Domain Admins" SePrintOperatorPrivilege

 net rpc rights grant -U $name "$domain\Domain Admins" SeAddUsersPrivilege

 net rpc rights grant -U $name "$domain\Domain Admins" SeDiskOperatorPrivilege

 net rpc rights grant -U $name "$domain\Domain Admins" SeRemoteShutdownPrivilege


fi

#reiniciamos el servicio

service smbd restart

service nmbd restart


clear


echo "This is your samba configuration"

#printamos la configuración final

testparm | more


echo "Enjoy your SAMBA domain!!!!! =)"

#Mostramos nuestro árbol del dominio

smbtree -N



