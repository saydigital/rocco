#Prepare arguments
while getopts d:f: flag
do
    case "${flag}" in
        d) dbname=${OPTARG};;
        f) dbfile=${OPTARG};;
    esac
done
echo "Restoring database $dbname from $dbfile"
# Move files
echo "Moving $dbfile to docker image"
docker cp $dbfile {{cookiecutter.project_code}}_postgres:/tmp/$dbname.sql
# Restore database
echo "Creating and restoring database $dbname"
docker exec {{cookiecutter.project_code}}_postgres createdb -U odoo $dbname
docker exec --workdir /tmp {{cookiecutter.project_code}}_postgres psql -U odoo -d $dbname -f $dbname.sql
docker exec --workdir /tmp {{cookiecutter.project_code}}_postgres rm $dbname.sql
