#!/bin/bash

# File name: restore-filestore.sh
# ############################################################################
# Description:  Copy target filestore to a docker contaniner. 
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
    echo "  -f       path to filestore"
    echo "  -r       docker container name"
    echo "  -h       show this help"
    echo " "
    exit 0
}

if [ "$#" -eq 0 ]; then
    show_usage
    exit 0
fi

while getopts "hd:f:r:" arg; do
  case $arg in
    h) show_usage ;;
    d) dbname=$OPTARG ;;
    f) filestorepath=$OPTARG ;;
    r) dockerrun=$OPTARG ;;
    *) break ;;
  esac
done
shift $(("$OPTIND" - 1))

# check for all options
: "${dbname:?Missing -d option}" "${dbfile:?Missing -f option}" "${dockerrun:?Missing -r option}"

echo "Restoring filestore $filestorepath for database $dbname in docker $dockerrun"
# Move files
echo "Moving files to docker image"
docker cp "${filestorepath}/." "${dockerrun}:/var/odoo/filestore/${dbname}/"
exit 0
