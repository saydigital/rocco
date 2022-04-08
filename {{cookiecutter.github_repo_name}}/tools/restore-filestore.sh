# Prepare arguments
while getopts d:f:r: flag
do
    case "${flag}" in
        d) dbname=${OPTARG};;
        f) filestorepath=${OPTARG};;
        r) dockerrun=${OPTARG};;
    esac
done
echo "Restoring filestore $filestorepath for database $dbname in docker $dockerrun"
# Move files
echo "Moving files to docker image"
docker cp $filestorepath/. $dockerrun:/var/odoo/filestore/$dbname/
