#!/bin/bash

# Variables de conexion DocumentDB
MONGO_HOST="mongocluster.cluster-ca9t8m6d2kmp.us-east-2.docdb.amazonaws.com:27017"
SSL_CA_FILE="global-bundle.pem"
USERNAME="facu"
PASSWORD="facu1234"

# Variables de conexion AWS S3
S3_BUCKET_NAME="facubackup"
AWS_API_KEY="AKIAXSL5LABEENSBCQVL"
AWS_SECRET_ACCESS_KEY="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"

# Directorio temporal de respaldo
BACKUP_DIR="./temp_backup"

# Configurar las credenciales de AWS en el entorno
export AWS_ACCESS_KEY_ID=$AWS_API_KEY
export AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY

#fecha y hora actual en el formato YYYYMMDD-HHMMSS
TIMESTAMP=$(date +'%Y%m%d-%H%M%S')

# Nombre de Cluster
CLUSTER_NAME="${MONGO_HOST%%.*}"

# Ruta en Amazon S3 con la fecha y hora actual en la ruta
S3_PATH="s3://$S3_BUCKET_NAME/$CLUSTER_NAME/$TIMESTAMP"

clear
echo -e "\n-----------------------------------------------------\n"

if [ "$EUID" -eq 0 ]; then
  # Conectar a DocumentDB y listar bases de datos
  databases=$(mongo --ssl --host $MONGO_HOST --sslCAFile $SSL_CA_FILE --username $USERNAME --password $PASSWORD --eval "db.getMongo().getDBs()" --quiet | grep 'name' | awk -F\" '{print $4}')

  echo -e "Bases de datos en DocumentDB:\n"
  echo "$databases"
  
  echo -e "\n-----------------------------------------------------\n"

  # Realizar copia de seguridad de cada base de datos
  for db in $databases
  do
    echo "Realizando copia de seguridad de la base de datos $db..."
    mongodump --ssl --host $MONGO_HOST --sslCAFile $SSL_CA_FILE --username $USERNAME --password $PASSWORD --db $db --out $BACKUP_DIR

    # Cargar la copia de seguridad en Amazon S3
    aws s3 cp $BACKUP_DIR/$db $S3_PATH/$db/ --recursive

    # Verificar el código de salida del comando aws s3 cp
    if [ $? -eq 0 ]; then
      echo -e "Copia de seguridad de la base de datos $db cargada en Amazon S3 en la ruta $S3_PATH/$db/\n"
      rm -rf $BACKUP_DIR/$db
    else
      echo -e "\n\n- Error al cargar la copia de seguridad de la base de datos $db en Amazon S3.\n\n\n"
    fi
  done
  
  echo -e "-----------------------------------------------------\n"

  # Verificar si la carpeta contiene archivos sin subir
  if [ "$(ls -A $BACKUP_DIR)" ]; then
    echo -e "Algo salio mal!!!\nPorfavor revise manualmente los archivos del backup en s3://$S3_BUCKET_NAME."
  else
    echo -e "Todas las copias de seguridad se completaron\ny cargaron en Amazon S3 en s3://$S3_BUCKET_NAME."
    rm -rf $BACKUP_DIR
  fi
  
else
  echo -e "El script necesita ejecutarse en modo Superusuario.\nIntente anteponer \"sudo\" al comando."
  echo -e "\n\nsudo bash $0"
fi

echo -e "\n-----------------------------------------------------\n"
