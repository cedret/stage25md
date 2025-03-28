#!/bin/bash
# genere un certificat de 2048 bits
# https://phil.writesthisblog.com/https-certificat-ssl-selfsigned/

if [ "x$1" = "x" ]
        then
        echo -e "usage: create_cert [file] [n]"
        echo -e "Will create a server key [file].key and a server certificate [file].crt valid for [n] days"
        exit 0
else
        NAME="$1"
fi

if [ "x$2" = "x" ] ; then TIME="365" ; else TIME="$2" ; fi

# genere une cle prive
echo -e "\nGenerating server key\n"
if ( ! openssl genrsa -out "$NAME.key" 2048 >> /dev/null 2>&1 ) ; then echo -e "Error" ; exit 1 ; fi

# cree un csr avec la cle privee
echo -e "\n\nGenerating certificate request\n"
openssl req -new -key "$NAME.key" -out "$NAME.csr"

# cree le certificat
echo -e "\n\nGenerating certificate\n"
openssl x509 -req -days "$TIME" -in "$NAME.csr" -signkey "$NAME.key" -out "$NAME.crt"

rm "$NAME.csr"
echo -e "\n$NAME.key: votre cle privee\n$NAME.crt: votre certificat serveur"

exit 0