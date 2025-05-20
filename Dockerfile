FROM ubuntu:22.04

# Evita domande interattive durante l'installazione dei pacchetti
ENV DEBIAN_FRONTEND=noninteractive

# Installa MySQL e altre utilità necessarie
RUN apt-get update && apt-get install -y \
    mysql-server \
    mysql-client \
    ncurses-bin \
    && rm -rf /var/lib/apt/lists/*

# Configurazione per permettere connessioni esterne
RUN sed -i 's/bind-address\s*=\s*127.0.0.1/bind-address = 0.0.0.0/' /etc/mysql/mysql.conf.d/mysqld.cnf

# Impostazione password e database
ENV MYSQL_ROOT_PASSWORD=root
ENV MYSQL_DATABASE=food_delivery_db

# Crea lo script di inizializzazione
COPY food-delivery-sql-fixed.sql /docker-entrypoint-initdb.d/1-schema.sql
COPY test-queries.sh /test-queries.sh
RUN chmod +x /test-queries.sh

# Crea uno script di entrypoint per inizializzare il database e avviare MySQL
RUN echo '#!/bin/bash\n\
# Avvia il servizio MySQL\n\
service mysql start\n\
\n\
# Attendere che MySQL si avvii completamente\n\
echo "Attesa avvio MySQL..."\n\
while ! mysqladmin ping -u root --silent; do\n\
    sleep 1\n\
done\n\
\n\
# Imposta la password di root\n\
mysql -e "ALTER USER \"root\"@\"localhost\" IDENTIFIED WITH mysql_native_password BY \"${MYSQL_ROOT_PASSWORD}\";"\n\
mysql -e "GRANT ALL PRIVILEGES ON *.* TO \"root\"@\"%\" IDENTIFIED BY \"${MYSQL_ROOT_PASSWORD}\" WITH GRANT OPTION;"\n\
mysql -e "FLUSH PRIVILEGES;"\n\
\n\
# Crea il database se non esiste\n\
mysql -u root -p${MYSQL_ROOT_PASSWORD} -e "CREATE DATABASE IF NOT EXISTS ${MYSQL_DATABASE};"\n\
\n\
# Importa lo schema\n\
echo "Importazione schema..."\n\
mysql -u root -p${MYSQL_ROOT_PASSWORD} ${MYSQL_DATABASE} < /docker-entrypoint-initdb.d/1-schema.sql\n\
\n\
# Mantieni il container in esecuzione\n\
echo "MySQL avviato e inizializzato!"\n\
exec "$@"\n\
' > /entrypoint.sh

RUN chmod +x /entrypoint.sh

# Esponi la porta MySQL
EXPOSE 3306

# Imposta l'entrypoint e il comando predefinito
ENTRYPOINT ["/entrypoint.sh"]
CMD ["tail", "-f", "/dev/null"]
