#!/bin/bash
#Variables pour la coloration syntaxique
# set -x 
blanc="\033[0m"
noir="\033[30m"
rouge="\033[31m"
vert="\033[32m"
orange="\033[33m"
jaune="\033[1;33m"


modicart()
{
    echo -e " Les paramètres renouvelés sont:"
    echo -e " Adresse IP \t $IP"
    echo -e " carte MASK \t $MASK"
    echo -e " carte GTW \t $GTW"
    echo -e " carte DNS \t $DNS"
    echo -e " La carte réseau va être purgée des anciens paramètres\t $NetCard"
    ip addr flush dev $NetCard
    ip addr add "$IP"/"$MASK" broadcast "$IPa.$IPb.$IPc.255" dev $NetCard
    ip route add default via "$GTW"
    ip a
    cible="/etc/resolv.conf"
    echo "#Modification du fichier resolv.conf" > $cible
    echo "nameserver $DNS"                     >>$cible
}

ajoulogi()
{
    echo -e "${vert} Vérification de la connexion à internet${jaune}"
    sites="iprec.fr yahoo.fr"
    erreurs=0
    for site in $sites
    do
        ping -c4 $site >/dev/null 2>&1
        ((erreurs+=$?))
    done
 
    if [ $erreurs -eq 0 ]
    then
        echo -e "${vert} Le reseau est ok${jaune}"
    else
        echo -e "${rouge} Probleme de reseau ${blanc}"
        exit13
    fi
    echo -e "${vert} Mise à jour de l'OS${jaune}"
    yum -y update
    echo -e "${vert} Ajout des packets nécessaires${blanc}"
    packages="dhcp-server.x86_64 tftp-server.x86_64 syslinux.x86_64 nfs4-acl-tools.x86_64 nfs-utils"
    erreurs=0
    for packet in $packages
    do
        yum -y install $packet
        ((erreurs+=$?))
    done

    echo -e "${vert} Ajout openjdk-8-jre${jaune}"
    sudo apt-get install openjdk-8-jre

    # ameliorer si erreur !=0
    echo -e "${vert} Vérification des packets${blanc}"
    erreurs=0
    for packet in $packages
    do
        rpm -q $packet
        ((erreurs+=$?))
    done
    echo -e "${vert} Vérification SElinux${blanc}"
    sestatus
}

echo -e "${jaune}\n******************* DEBUT ***********************${blanc}"
echo -e "${rouge}VMware peut présenter des bugs, dans ce cas redémarrer toute la machine${blanc}"
echo -e "${jaune}ATTENTION avec une distribution minimaliste, VSCode peut refuser de se connecter en SSH,"
echo -e " et des commandes comme VIM peuvent manquer par défaut.\n\n${blanc}"
# si EUID = 0 afficher en vert le script va s'executer et bascule jaune
# sinon en reouge, passer root pour executer le script, bascule jaune
# sortir du script

#verifier fonctions.sh est ordinaire et executable
#si oui, executer
#sinon en ROUGE, afficher fonctions.sh manquant ou non executable
#basculer en jaune

if [ -f fonctions.sh -a -x fonctions.sh ]
then
    . fonctions.sh
else
    echo -e "${rouge} Fichier fonctions.sh est manquant ou non executable ${blanc}"
    exit
fi

VerifRoot

ip -4 a





echo -e "${jaune}Entrez 11 configurer une IP en bridge"
echo -e " ou autre valeur pour sauter l'étape.${blanc}"
read reponse
if [ $reponse -eq 11 ]
then
    echo -e "Merci de configurer la carte réseau en bridge, puis ENTER"
    read reponse
    echo "***** ConfigNETCARD *****"
    ConfigNETCARD
    echo "***** ConfigIP *****"
    ConfigIP
    echo "***** ConfigMASK *****"
    ConfigMASK
    echo "***** ConfigGTW *****"
    ConfigGTW
    echo "***** ConfigDNS *****"
    ConfigDNS
    modicart
fi

echo -e "${jaune}Entrez 12 si vous voulez installer les compléments logiciels"
echo -e " ou autre valeur pour sauter l'étape.${blanc}"
read reponse
if [ $reponse -eq 12 ]
then
    ajoulogi
fi

ip a
echo -e "${jaune}Entrez 13 pour configurer une ip pour serveur PXE"
echo -e " ou autre valeur pour sauter l'étape.${blanc}"
read reponse
if [ $reponse -eq 13 ]
then
    echo -e "Paramétrer avec les valeurs suivantes"
    echo -e "IP = 192.168.C.254"
    echo -e "MASQUE = 255.255.255.0"
    echo -e "PASSERELLE = 192.168.C.254"
    echo -e "DNS = 192.168.C.254"
    echo -e " où C est votre année de naissance (uniquement les deux derniers chiffres)"
    echo -e "Pour commencer:"
    echo -e "Merci de configurer la carte réseau en host-only, puis ENTER"
    read reponse
    echo "***** ConfigNETCARD ***** "
    ConfigNETCARD
    echo "***** ConfigIP ***** "
    ConfigIP
    echo "***** ConfigMASK ***** "
    ConfigMASK
    echo "***** ConfigGTW ***** "
    ConfigGTW
    echo "***** ConfigDNS ***** "
    ConfigDNS
    modicart
fi
echo -e "***** Rappel des paramètres actuels de la carte ******"
echo -e "${orange}IPa=$IPa IPb=$IPb IPc=$IPc IPd=$IPd${jaune}"
DNS=$DNSa.$DNSb.$DNSc.$DNSd
echo -e "${orange}DNSa=$DNSa DNSb=$DNSb DNSc=$DNSc DNSd=$DNSd${blanc}"
echo "$IPa.$IPb.$IPc.$IPd-$MASK-$GTW-$DNS"

echo -e "${jaune}Entrez 14 si vous voulez activer les services dhcp et tftp"
echo -e " ou autre valeur pour sauter l'étape (déconseillé).${blanc}"
read reponse
if [ $reponse -eq 14 ]
then
    cible2="/etc/dhcp/dhcpd.conf"
    echo "authoritative;"                               > $cible2
    echo "subnet $IPa.$IPb.$IPc.0 netmask $MASK {"      >>$cible2
    echo "range $IPa.$IPb.$IPc.100 $IPa.$IPb.$IPc.110;" >>$cible2
    echo "option routers $GTW;"                         >>$cible2
    echo "option domain-name-servers $DNS;"             >>$cible2
    echo "option broadcast-address $IPa.$IPb.$IPc.255;" >>$cible2
    echo "next-server $IP;"                             >>$cible2
    echo "option subnet-mask $MASK;"                    >>$cible2
    echo "filename \"pxelinux.0\";"                     >>$cible2
    echo "}"                                            >>$cible2

    echo "***** dhcpd.conf actuel" 
    cat /etc/dhcp/dhcpd.conf

    systemctl restart dhcpd.service && systemctl enable dhcpd.service
    systemctl status dhcpd.service

    systemctl restart tftp.socket && systemctl enable tftp.socket
    systemctl status tftp.socket

    echo "***** copie de fichiers et création de dossier"
    cp /usr/share/syslinux/{pxelinux.0,ldlinux.c32} /var/lib/tftpboot/
    cp /usr/share/syslinux/ldlinux.c32 /var/lib/tftpboot/
    [ -d /var/lib/tftpboot/pxelinux.cfg ] || mkdir /var/lib/tftpboot/pxelinux.cfg
    [ -d /SrcAlma ] || mkdir /SrcAlma
    [ -d /reponses ] || mkdir /reponses
fi

echo -e "${jaune}Entrez 15 si vous voulez connecter DVD avec fichier ISO"
echo -e " ou autre valeur pour sauter l'étape.${blanc}"
read reponse
if [ $reponse -eq 15 ]
then
# echo -e "${rouge} Vérifier que le lecteur est connecté avec un fichier ISO dedans${jaune}"
# echo -e "Appuyer sur entrée"
# read reponse
    mount /dev/sr0 /SrcAlma/
    cible="/var/lib/tftpboot/pxelinux.cfg/default"
    echo "PROMPT 0" >$cible
    echo "DEFAULT linux" >>$cible
    echo "LABEL linux" >>$cible
    echo "KERNEL vmlinuz" >>$cible
    echo "APPEND initrd=initrd.img inst.ks=nfs:$IP:/reponses/ks.cfg" >>$cible
    cp /SrcAlma/images/pxeboot/{vmlinuz,initrd.img} /var/lib/tftpboot/
    cible="/etc/exports"
    echo "/SrcAlma $IPa.$IPb.$IPc.0/24(ro,sync,no_root_squash,no_subtree_check)" >$cible
    echo "/reponses $IPa.$IPb.$IPc.0/24(ro,sync,no_root_squash,no_subtree_check)" >>$cible
fi

echo -e "${jaune}Entrez 16 pour activer NFS"
echo -e " ou autre valeur pour sauter l'étape.${blanc}"
read reponse
if [ $reponse -eq 16 ]
then
    systemctl restart nfs-server.service && systemctl enable nfs-server.service
    systemctl status nfs-server.service

    exportfs -v
    firewall-cmd --permanent --add-service=tftp
    firewall-cmd --permanent --add-service=nfs
    firewall-cmd --permanent --add-service=rpc-bind
    firewall-cmd --permanent --add-service=mountd
    systemctl restart firewalld.service
fi

echo -e "${jaune}Entrez 17 pour remplacer ks.cfg pour distribution minimale"
echo -e "${jaune}Entrez 18 pour remplacer ks.cfg pour distribution maximale"
echo -e " ou autre valeur pour sauter l'étape.${blanc}"
read reponse
# Fichier Kickstart à modifier

if [ $reponse -eq 17 ]
then
    cp -f /root/anaconda-ks.cfg ks.cfg
    cp -f mini.cfg /reponses/ks.cfg
else
    if  [ $reponse -eq 18 ]
    then
            cp -f /root/anaconda-ks.cfg ks.cfg
            cp -f maxi.cfg /reponses/ks.cfg
    fi
fi

echo -e "${orange}***** Script terminé ******"
echo -e "${blanc}***** L'Os peut être installé sur une nouvelle machine ******${blanc}"

#----------------
#ks_file="ks.cfg"
# Vérifie si la ligne contient "cdrom" et remplace par la nouvelle ligne
#    if grep -q "cdrom" "$ks_file"; then
#        sed -i 's|cdrom|nfs --server=192.168.72.254 --dir=/SrcAlma|' "$ks_file"
#        echo "La ligne 'cdrom' a été remplacée par 'nfs --server=192.168.72.254 --dir=/SrcAlma'."
#    else
#        echo "La ligne 'cdrom' n'a pas été trouvée dans le fichier."
#fi

