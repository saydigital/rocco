# Change database UUID
echo "Change database UUID"
new_uuid=$(uuidgen)
docker exec {{cookiecutter.project_code}}_postgres psql -U odoo -c "UPDATE ir_config_parameter SET value = '${new_uuid}' WHERE key='database.uuid';" "$@"
echo "New UUID: ${new_uuid}"

# Disable Mail Server
echo "Disabling mail server"
docker exec {{cookiecutter.project_code}}_postgres psql -U odoo -c "UPDATE ir_mail_server SET active = false;" "$@"
docker exec {{cookiecutter.project_code}}_postgres psql -U odoo -c "UPDATE ir_mail_server SET smtp_user = CONCAT(smtp_user, '.test'), smtp_host = CONCAT(smtp_host, '.test');" "$@"

# Disable Cron
echo "Disabling cron"
docker exec {{cookiecutter.project_code}}_postgres psql -U odoo -c "UPDATE ir_cron SET active = false;" "$@"

# Change admin user and password
echo "Change admin password"
python_code="from passlib.context import CryptContext
setpw = CryptContext(schemes=['pbkdf2_sha512'])
print(setpw.hash('admin'))"
admin_password=$(python3 -c "$python_code")
echo "New password: admin (${admin_password})"
docker exec {{cookiecutter.project_code}}_postgres psql -U odoo -c "UPDATE res_users SET login='admin', password = '${admin_password}' WHERE id=2;" "$@"

# Change users password
echo "Change users password"
python_code="from passlib.context import CryptContext
setpw = CryptContext(schemes=['pbkdf2_sha512'])
print(setpw.hash('test'))"
users_password=$(python3 -c "$python_code")
echo "New password: test (${users_password})"
docker exec {{cookiecutter.project_code}}_postgres psql -U odoo -c "UPDATE res_users SET password = '${users_password}' WHERE id != 2;" "$@"
