# https://phil.writesthisblog.com/https-certificat-ssl-selfsigned/
# https://wiki.mozilla.org/Security/Server_Side_TLS#Nginx

server {
    listen 443 ssl;
    server_name www.mondomaine.com;

    # certs sent to the client in SERVER HELLO are concatenated in ssl_certificate
    ssl_certificate /chemin/vers/votre_certificat_serveur_auto_signe.crt;
    ssl_certificate_key /chemin/vers/la_cle_privee.key;
    # Diffie-Hellman parameter for DHE ciphersuites, recommended 2048 bits
    # ssl_dhparam /path/to/dhparam.pem;
    ssl_session_timeout 5m;
    ssl_protocols SSLv3 TLSv1 TLSv1.1 TLSv1.2;
    ssl_ciphers ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-AES256-GCM-SHA384:DHE-RSA-AES128-GCM-SHA256:DHE-DSS-AES128-GCM-SHA256:kEDH+AESGCM:ECDHE-RSA-AES128-SHA256:ECDHE-ECDSA-AES128-SHA256:ECDHE-RSA-AES128-SHA:ECDHE-ECDSA-AES128-SHA:ECDHE-RSA-AES256-SHA384:ECDHE-ECDSA-AES256-SHA384:ECDHE-RSA-AES256-SHA:ECDHE-ECDSA-AES256-SHA:DHE-RSA-AES128-SHA256:DHE-RSA-AES128-SHA:DHE-DSS-AES128-SHA256:DHE-RSA-AES256-SHA256:DHE-DSS-AES256-SHA:DHE-RSA-AES256-SHA:AES128-GCM-SHA256:AES256-GCM-SHA384:ECDHE-RSA-RC4-SHA:ECDHE-ECDSA-RC4-SHA:AES128:AES256:RC4-SHA:HIGH:!aNULL:!eNULL:!EXPORT:!DES:!3DES:!MD5:!PSK;
    ssl_prefer_server_ciphers   on;
    ssl_session_cache           shared:SSL:10m;

    ...
}