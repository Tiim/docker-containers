#!/usr/bin/env bash


set -o errexit
# set -o nounset
set -o pipefail

function check_env {
    [ -z "$PASS" ] && { echo "PASS variable is required"; exit 1; } || true
    [ -z "$HOST" ] && { echo "HOST variable is required"; exit 1; } || true
    [ -z "$PROTOCOL" ] && { echo "PROTOCOL variable is required"; exit 1; } || true
    [ -z "$DB_NAME" ] && { echo "DB_NAME variable is required"; exit 1; } || true
    [ -z "$DB_TYPE" ] && { echo "DB_TYPE variable is required"; exit 1; } || true
    [ -z "$LANG" ] && { echo "LANG variable is required"; exit 1; } || true
    [ -z "$NAME" ] && { echo "NAME variable is required"; exit 1; } || true
    [ -z "$ADMIN" ] && { echo "ADMIN variable is required"; exit 1; } || true
}

check_env

# DB_NAME the database name
# DB_PASS the database password
# DB_SERVER the database server uri
# DB_TYPE the db type
# DB_USER the db user
# HOST the host of the wiki
# LANG the language of the wiki
# PASS the password of the admin account
# PROTOCOL the protocol of the wiki
# NAME the name of the wiki
# ADMIN the name of the admin account

SETTINGS_FILE_TMPL=LocalSettings.tmpl.php
SETTINGS_FILE_BARE=LocalSettings-bare.php
SETTINGS_FILE=LocalSettings.php
SERVER=$PROTOCOL://$HOST


MAINT=maintenance/run.php


function get_db_host_and_port {
    if [[ "$DB_SERVER" =~ :[0-9]+ ]]; then
        DB_HOSTNAME="${DB_SERVER%:*}"
        DB_PORT="${DB_SERVER#*:}"
    else
        echo "HOST does not matche regex $DB_SERVER"
        DB_HOSTNAME="$DB_SERVER"
        case "$DB_TYPE" in
            "postgres") DB_PORT="5432"
            ;;
            "mysql") DB_PORT="3306"
            ;;
            *)
                echo "Database $DB_TYPE has no port"
                exit 1
            ;;
        esac
    fi
}


function place_settings_file {
    echo "Placing template settings file"
    cp "$SETTINGS_FILE_TMPL" "$SETTINGS_FILE"
    echo "$SETTINGS_FILE_TMPL" > settingsfile.txt
}

function place_bare_settings_file {
    # echo "Placing bare settings file"
    # cp "$SETTINGS_FILE_TMPL" "$SETTINGS_FILE"
    # cp "$SETTINGS_FILE_BARE" "$SETTINGS_FILE"
    # echo "$SETTINGS_FILE_BARE" > settingsfile.txt
    place_settings_file
}

function remove_settings_file {
    echo "Removing settings file"
    rm "$SETTINGS_FILE"
}

function check_db {
    echo "Checking dababase status"
    db_status="bad"
    php $MAINT sql --query "SELECT user_name from user;" --json --status &> /dev/null&& db_status="good" || db_status="bad";
    echo "Status: $db_status"
}

function install {
    echo "Running the installer"
    # https://www.mediawiki.org/wiki/Manual:Install.php
    php $MAINT install \
        --server "$SERVER" \
        --dbuser "$DB_USER" \
        --dbpass "$DB_PASS" \
        --dbname "$DB_NAME" \
        --dbserver "$DB_SERVER" \
        --dbtype "$DB_TYPE" \
        --lang "$LANG" \
        --pass "$PASS" \
        --scriptpath "" \
        --dbpath "/var/www/data" \
        "$NAME" $ADMIN
    chown -R www-data:www-data /var/www/data
}

function update {
    echo "Running the updater"
    place_settings_file
    php $MAINT update
    php extensions/SemanticMediaWiki/maintenance/setupStore.php
    # php extensions/SemanticMediaWiki/maintenance/rebuildData.php -vfp
    php extensions/SemanticMediaWiki/maintenance/rebuildData.php -v
}


echo "Check if database reachable..."
if [ "$DB_TYPE" != "sqlite" ]; then
    get_db_host_and_port
    echo "Waiting for db at $DB_HOSTNAME:$DB_PORT"
    ./wait-for-it.sh -h "$DB_HOSTNAME" -p "$DB_PORT" -t 0
fi

if [ -f $SETTINGS_FILE ]; then
    echo "Settings file $SETTINGS_FILE exists. Skipping initialization."
else
    echo "Settings file $SETTINGS_FILE does not exist."
    place_bare_settings_file

    check_db
    if [ "$db_status" = "bad" ]; then
        remove_settings_file
        install
    fi
fi;


update

echo "Settings file loaded: $(cat settingsfile.txt)"
sleep 2
echo "exec: $@"
exec "$@"
