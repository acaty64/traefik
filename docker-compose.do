version: '3'

services:
    reverse-proxy:
        image: traefik:v2.1
        container_name: proxy
        ports:
            - "80:80"
            - "443:443"
            - "8080:8080"

        volumes:
            - /var/run/docker.sock:/var/run/docker.sock
            - ./traefik.yml:/traefik.yml
            - ./acme.json:/acme.json
            - ./traefik.log:/traefik.log
        labels:
            - "traefik.enable=true"

    nginx:
        image: nginx
        container_name: nginx
        labels:
            - "traefik.enable=true"
            - "traefik.http.routers.nginx.rule=Host(`disponibilidad.ucssfcec.xyz`)"
            - "traefik.http.routers.nginx.entrypoints=websecure"
            - "traefik.http.routers.nginx.tls.certresolver=myresolver"

    web-0:
        image: acaty/ucssfcec:1.0.1
        container_name: nginx-ucssfcec
        restart: always
        labels:
            # - "environment=production"
            - "traefik.enable=true"
            - "traefik.http.routers.web-0.rule=Host(`ucssfcec.xyz`)"
            - "traefik.http.routers.web-0.entrypoints=websecure"
            - "traefik.http.routers.web-0.tls.certresolver=myresolver"
        volumes:
            - ~/code/ucssfcec:/usr/share/nginx/html:rw
            - ./dockerfiles/sites-available/ucssfcec.xyz:/etc/nginx/sites-available/default
            - ~/code/mysql:/var/lib/mysql:rw

    web-1:
        image: acaty/firma:1.0.2
        container_name: nginx-firma
        restart: always
        labels:
            - "environment=production"
            - "traefik.enable=true"
            - "traefik.http.routers.web-1.rule=Host(`firma.ucssfcec.xyz`)"
            - "traefik.http.routers.web-1.entrypoints=websecure"
            - "traefik.http.routers.web-1.tls.certresolver=myresolver"
        volumes:
            - ~/code/firma:/usr/share/nginx/html:rw
            - ./dockerfiles/sites-available/firma.xyz:/etc/nginx/sites-available/default
            - ~/code/mysql:/var/lib/mysql:rw

    web-2:
        image: acaty/call:1.0.0
        container_name: call
        restart: always
        ports:
            - "6001:6001"
        labels:
            - "environment=production"
            - "traefik.enable=true"
            - "traefik.http.routers.web-2.rule=Host(`store.ucssfcec.xyz`)"
            # - "traefik.http.routers.web-2.entrypoints=web"
            - "traefik.http.routers.web-2.entrypoints=websecure"
            - "traefik.http.routers.web-2.tls.certresolver=myresolver"
            # - "--entrypoints.web.address=:80"
            - "--entryPoints.ws.address=:6001"
        volumes:
            - ~/code/call8:/usr/share/nginx/html:rw
            - ~/code/mysql:/var/lib/mysql:rw
            - ./dockerfiles/sites-available/call.xyz:/etc/nginx/sites-available/default
            - ./dockerfiles/public/htaccess.https:/usr/share/nginx/html/public/.htaccess

    mysql:
        container_name: mysql
        image: mysql:5.7
        # restart: always
        labels:
            # - "environment=production"
            - "traefik.enable=true"
        ports:
            - "${DB_PORT}:3306"
        environment:
            MYSQL_USER: "${MYSQL_USER}"
            MYSQL_ROOT_PASSWORD: "ucss20505378629"
            MYSQL_PASSWORD: "${MYSQL_PASSWORD}"
        volumes:
            - ~/code/mysql:/var/lib/mysql:rw
            - ./dockerfiles/mysql/mysql.cnf:/etc/mysql/conf.d/mysql.cnf
            - ./dockerfiles/mysql/my.cnf:/etc/mysql/my.cnf

