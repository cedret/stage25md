    12)
        # Variables
        SERVER_NAME="rp.test.fv"         # Le nom de domaine (ou IP)
        BACKEND_IP="192.168.80.139"      # IP du serveur backend
        BACKEND_PORT="443"               # Port backend
        NGINX_CONF="/etc/nginx/sites-available/$SERVER_NAME"
        CERT_DIR="/etc/ssl/nginx/$SERVER_NAME"
        echo -e "${vert}========== 34.0 Install SS-SSL RVPX (self-signed SSL)${blanc} [$(hostname)]"
        echo -e "\n${vert}----- Créations dossier, clé, certif, pré-rempli ici avec IP du RVPX${blanc}"
        sudo mkdir -p /etc/ssl/rvpx
        sudo openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
             -keyout $CERT_DIR/selfsigned.key \
             -out $CERT_DIR/selfsigned.crt \
             -subj "/C=FR/ST=IDF/L=IVRY/O=auto/CN=$SERVER_NAME"
        cat <<EOF | sudo tee $NGINX_CONF > /dev/null
        server {
            listen 443 ssl;
            server_name $SERVER_NAME;
        
            ssl_certificate     $CERT_DIR/selfsigned.crt;
            ssl_certificate_key $CERT_DIR/selfsigned.key;
        
            location / {
                proxy_pass http://$BACKEND_IP:$BACKEND_PORT;
                proxy_set_header Host \$host;
                proxy_set_header X-Real-IP \$remote_addr;
                proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
            }
        }
        
        # Redirige HTTP vers HTTPS
        server {
            listen 80;
            server_name $SERVER_NAME;
            return 301 https://\$host\$request_uri;
        }
EOF
        
        echo -e "\n${jaune}Création du lien vers /sites-enabled/"
        sudo ln -s $NGINX_CONF /etc/nginx/sites-enabled/
            
        echo -e "\n${jaune}Test et rechargement de la configuration Nginx"
        sudo nginx -t && sudo systemctl reload nginx
        
        echo -e "\n${jaune}Suppression site par défaut (si présent)"
        if [ -e /etc/nginx/sites-enabled/default ];
         then
          echo "Suppression du site 'default'..."
          sudo rm /etc/nginx/sites-enabled/default
        fi
    
        echo "Nginx est configuré avec SSL auto-signé vers $BACKEND_IP:$BACKEND_PORT"
        echo "Tester : https://$SERVER_NAME (accepte le certificat auto-signé)"
    
        echo -e "${jaune} sudo nginx -t && sudo systemctl reload nginx"
        echo -e "${vert}--------- Tester... (verif rvpx)"
        echo -e "${jaune}..... curl -k https://rp.test.fv"
        echo -e "${jaune}..... sudo ufw allow 'Nginx Full'"
        echo -e "${jaune}..... sudo ufw delete allow 'Nginx HTTP'"
        ;;