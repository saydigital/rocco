#!/bin/bash

# File name: restore-db.sh
# ############################################################################
# Description:  Restores a postgres dump.
#
# ----------------------------------------------------------------------------
# Rapsodoo Italia srl
# ############################################################################
# shellcheck disable=SC1083 #Disable this check because script has cookiecutter template parts.

show_usage(){
    echo ""
    echo "Use: $(basename $0) -d database_name -f /path/to/dump.sql"
    echo "Options:"
    echo "  -d       target database name"
    echo "  -f       path to the postgres database dump"
    echo "  -h       show this help"
    echo " "
    exit 0
}

if [ "$#" -eq 0 ]; then
    show_usage
    exit 0
fi

while getopts "hd:f:" arg; do
  case $arg in
    h) show_usage ;;
    d) dbname=$OPTARG ;;
    f) dbfile=$OPTARG ;;
    *) break ;;
  esac
done
shift $(("$OPTIND" - 1))

# check for all options
: "${dbname:?Missing -d option}" "${dbfile:?Missing -f option}"


echo "Restoring database $dbname from $dbfile"
# Move files
echo "Moving $dbfile to docker image"
docker cp "$dbfile" {{cookiecutter.project_code}}_postgres:"/tmp/${dbname.sql}"
# Restore database
echo "Creating and restoring database $dbname"
docker exec {{cookiecutter.project_code}}_postgres createdb -U odoo "$dbname"
docker exec --workdir /tmp {{cookiecutter.project_code}}_postgres psql -U odoo -d "$dbname" -f "${dbname}.sql"
docker exec --workdir /tmp {{cookiecutter.project_code}}_postgres rm "${dbname}.sql"

exit 0
