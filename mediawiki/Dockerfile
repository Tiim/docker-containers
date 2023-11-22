FROM mediawiki:1.40.1

# https://www.mediawiki.org/wiki/Docker/Hub

RUN apt-get update && apt-get install -y \
    libzip-dev \
    libpq-dev

# install composer
RUN php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" && \
    php -r "if (hash_file('sha384', 'composer-setup.php') === 'e21205b207c3ff031906575712edab6f13eb0b361f2085f1f1237b7126d785e826a450292b6cfd1d64d92e6563bbde02') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;" && \
    php composer-setup.php && \
    php -r "unlink('composer-setup.php');"

# install php extensions
RUN docker-php-ext-install -j$(nproc) zip pgsql;

COPY *.sh ./
RUN chmod +x *.sh
ENTRYPOINT [ "./docker-init.sh" ]
CMD ["apache2-foreground"]

# install mediawiki extensions
COPY composer.local.json /var/www/html/composer.local.json
RUN php composer.phar update --no-dev


COPY LocalSettings.php LocalSettings.tmpl.php
# COPY LocalSettings-bare.php LocalSettings-bare.php


# Volumes:
# /var/www/data -> SQLite Database
# /var/www/html/images -> Uploads
# /var/www/html/LocalSettings.php -> LocalSettings.php
