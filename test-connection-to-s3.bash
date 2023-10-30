#!/bin/bash

# Variables de conexion AWS S3
S3_BUCKET_NAME="facubackup"
AWS_API_KEY="AKIAXSL5LABEENSBCQVL"
AWS_SECRET_ACCESS_KEY="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"

# Configurar las credenciales de AWS en el entorno
export AWS_ACCESS_KEY_ID=$AWS_API_KEY
export AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY

FILE_NAME="test_connection_to_s3.txt"

clear
echo -e "\n-----------------------------------------------------\n"

if [ "$EUID" -eq 0 ]; then
  # Crear un archivo de prueba
  echo "Test connection to S3." > $FILE_NAME

  # Subir el archivo al depósito S3
  aws s3 cp test_connection_to_s3.txt s3://$S3_BUCKET_NAME/

  # Verificar el código de salida del comando aws s3 cp
  if [ $? -eq 0 ]; then
    echo "Archivo cargado con éxito en el depósito S3: s3://$S3_BUCKET_NAME/$FILE_NAME"
  else
    echo "No se pudo cargar el archivo en el depósito S3: s3://$S3_BUCKET_NAME/$FILE_NAME"
  fi

  # Eliminar el archivo de prueba local
  rm $FILE_NAME

else
  echo -e "El script necesita ejecutarse en modo Superusuario.\nIntente anteponer \"sudo\" al comando."
  echo -e "\n\nsudo bash $0"
fi

echo -e "\n-----------------------------------------------------\n"