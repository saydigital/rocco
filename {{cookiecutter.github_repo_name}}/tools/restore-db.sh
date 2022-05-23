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
    echo "Use: $(basename $0) -d database_name -f /path/to/sql-dump"
    echo "Options:"
    echo "  -d       target database name"
    echo "  -f       path to the postgres database dump (can be text or gzipped)"
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

# check if dump is gzipped, unzip it in place if so
if file "$dbfile" | grep -q gzip ; then
    echo "file is compressed, uncompressing"
    gunzip "$dbfile"
    # cleanup .gz extension
    filename=$(basename "$dbfile" .gz)
    filepath=$(dirname "$dbfile")
    dbfile="${filepath}/${filename}"
fi

echo "Restoring database $dbname from $dbfile"
# Move files
echo "Moving $dbfile to docker image"
docker cp "$dbfile" {{cookiecutter.project_code}}_postgres:"/tmp/${dbname}.sql"
# Restore database
echo "Creating and restoring database $dbname"
docker exec {{cookiecutter.project_code}}_postgres createdb -U odoo "$dbname"
docker exec --workdir /tmp {{cookiecutter.project_code}}_postgres psql -U odoo -d "$dbname" -f "${dbname}.sql"
docker exec --workdir /tmp {{cookiecutter.project_code}}_postgres rm "${dbname}.sql"

exit 0
