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
S3_PATH="s3://$S3_BUCKET_NAME/$CLUSTER_NAME"

clear
echo -e "\n-----------------------------------------------------\n"

if [ "$EUID" -eq 0 ]; then
  # Comprobar si el directorio de destino existe; si no, créalo
  if [ ! -d "$BACKUP_DIR" ]; then
    mkdir -p "$BACKUP_DIR"
  fi
  
  # Verificar copias de seguridad existentes en Amazon S3
  if aws s3 ls "$S3_PATH" > /dev/null 2>&1; then
    # Obtener la última copia de seguridad
    LAST_BACKUP=$(aws s3 ls "$S3_PATH/" | awk -F' ' '{print $2}' | sort -r | head -n 1)

    if [ ! -z "$LAST_BACKUP" ]; then
      # Descargar la última copia de seguridad
      echo "Descargando la última copia de seguridad desde Amazon S3...\n"
      aws s3 cp "$S3_PATH/$LAST_BACKUP" "$BACKUP_DIR/$LAST_BACKUP" --recursive
      if [ $? -eq 0 ]; then
        LAST_BACKUP_PATH="$BACKUP_DIR/$LAST_BACKUP/"
        echo -e "\nDescarga completada!!!\n"
        # Utiliza el comando mongorestore para restaurar todas las bases de datos y colecciones desde el directorio de respaldo
        mongorestore --ssl --host $MONGO_HOST --sslCAFile $SSL_CA_FILE --username $USERNAME --password $PASSWORD --dir $LAST_BACKUP_PATH
        # Verificar el código de salida del comando mongorestore
        if [ $? -eq 0 ]; then
          echo "Restauración exitosa de bases de datos y colecciones desde el archivo de respaldo."
          rm -rf $BACKUP_DIR
        else
          echo -e "\n- Error al restaurar bases de datos y colecciones desde el archivo de respaldo."
        fi
      else
        echo -e "\n- Error al descargar el backup desde Amazon S3."
      fi
    else
      echo -e "\nNo se encontraron copias de seguridad en la ruta $S3_PATH/"
    fi
  else
    echo -e "\nNo se ecnontraron copias de seguridad en la ruta $S3_PATH/"
  fi
else
  echo -e "El script necesita ejecutarse en modo Superusuario.\nIntente anteponer \"sudo\" al comando."
  echo -e "\n\nsudo bash $0"
fi

echo -e "\n-----------------------------------------------------\n"
