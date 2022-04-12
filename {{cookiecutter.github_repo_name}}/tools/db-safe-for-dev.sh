#!/bin/bash

# File name: db-safe-for-dev.sh
# ############################################################################
# Description:  Clean up an Odoo database to make it safe for dev use.
# ----------------------------------------------------------------------------
# Rapsodoo Italia srl
# ############################################################################
# shellcheck disable=SC1083 #Disable this check because script has cookiecutter template parts.

show_usage(){
    echo ""
    echo "Use: $(basename $0) -d database_name"
    echo -e "Pass target database name to the script\n\tTarget database will be sanitized." 
    echo "Options:"
    echo "  -d       target database name"
    echo "  -h       show this help"
    echo " "
    exit 0
}

if [ "$#" -eq 0 ]; then
    show_usage
    exit 0
fi

while getopts "hd:" arg; do
  case $arg in
    h) show_usage ;;
    d) dbname=$OPTARG ;;
    *) break ;;
  esac
done
shift $(("$OPTIND" - 1))

# check for all options
: "${dbname:?Missing -d option}"


# Change database UUID
echo "Change database UUID"
new_uuid=$(uuidgen)
docker exec {{cookiecutter.project_code}}_postgres psql -U odoo -d "$dbname" -c "UPDATE ir_config_parameter SET value = '${new_uuid}' WHERE key='database.uuid';" "$@"
echo "New UUID: ${new_uuid}"

# Disable Mail Server
echo "Disabling mail server"
docker exec {{cookiecutter.project_code}}_postgres psql -U odoo -d "$dbname" -c "UPDATE ir_mail_server SET active = false;" "$@"
docker exec {{cookiecutter.project_code}}_postgres psql -U odoo -d "$dbname" -c "UPDATE ir_mail_server SET smtp_user = CONCAT(smtp_user, '.test'), smtp_host = CONCAT(smtp_host, '.test');" "$@"

# Disable Cron
echo "Disabling cron"
docker exec {{cookiecutter.project_code}}_postgres psql -U odoo -d "$dbname" -c "UPDATE ir_cron SET active = false;" "$@"

# Change admin user and password
echo "Change admin password"
python_code="from passlib.context import CryptContext
setpw = CryptContext(schemes=['pbkdf2_sha512'])
print(setpw.hash('admin'))"
admin_password=$(python3 -c "$python_code")
echo "New password: admin (${admin_password})"
docker exec {{cookiecutter.project_code}}_postgres psql -U odoo -d "$dbname" -c "UPDATE res_users SET login='admin', password = '${admin_password}' WHERE id=2;" "$@"

# Change users password
echo "Change users password"
python_code="from passlib.context import CryptContext
setpw = CryptContext(schemes=['pbkdf2_sha512'])
print(setpw.hash('test'))"
users_password=$(python3 -c "$python_code")
echo "New password: test (${users_password})"
docker exec {{cookiecutter.project_code}}_postgres psql -U odoo -d "$dbname" -c "UPDATE res_users SET password = '${users_password}' WHERE id != 2;" "$@"

exit 0
