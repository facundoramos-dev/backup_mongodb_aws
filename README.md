# Instrucciones a realizar

## Crear un Bucket S3

> _El Bucket S3 servirá para almacenar las base de datos MongoDB de **DocumentDB**_

1. Entrar en **AWS S3**.
2. Dar click en _"Crear un Bucket"_.
3. Eligir un nombre para el bucket y dar click en **"Crear Bucket"**.

## Crear una política IAM

> _La política es la que nos permitirá realizar acciones de lectura y escrituras sobre nuestro **bucket S3**_

1. Entrar en **AWS IAM**.
2. Entrar en _"Políticas"_.
3. Dar click en _"Crear Política"_.
4. Elegir formato **JSON**.
5. Elegir unas políticas de seguridad, puede tomar de ejemplo el archivo **user-policy-aws-s3.json**. Si desea usar este archivo deberá cambiar el **NAME_BUCKET** por el nombre del bucket elegido y dar click en **"Siguiente"**.
6. Eligir un nombre, por ejemplo **user-policy-s3-backup** y agregar una descripción y dar click en **"Crear Política"**.

## Crear un usuario IAM

> _El usuario servirá para permitir la conexión a nuestro **bucket S3**_

1. Entrar en **AWS IAM**.
2. Entrar en _"Usuarios"_.
3. Dar click en _"Crear Usuario"_.
4. Elegir el nombre de usuario, por ejemplo **"user-s3-backup"** y dar click en **Siguiente**.
5. En _"Opciones de permisos"_ seleccionar **"Adjuntar políticas directamente"**.
6. Indiciar la política correspondiente, dar click en **Siguiente** y en **Crear Usuario**.

## Crear una clave para un usuario en IAM

> _La clave servirá para permitir a una aplicación externa identificarse como el usuario **IAM** seleccionado_

1. Seleccionar en usuario en cual desea crear una clave.
2. Desplazarte hacia abajo y seleccionar **"Credenciales de seguridad"**.
3. Desplazarse hasta **"Claves de acceso"** y dar click en **"Crear clave de acceso"**.
4. En _"Caso de uso"_ seleccionar **"Otros"** y dar click en **"Siguiente"**.
5. Elegir un _"Valor de etiqueta de descripción"_, este sera un nombre con el cual asociar la clave por ejemplo **"connection_s3"** y dar click en **"Crear"**.
6. Sin salir de esta pantalla, copiar y anotar **"Clave de acceso"** y la **"Clave de acceso secreta"**, una vez apuntado estos datos puede dar click en **"Listo"** o cerrar la pagina.

## Crear un entorno en Cloud9

> _El entorno Cloud9 servirá para conectarse a **DocumentDB**_

1. Entrar en un entorno **AWS CLOUD9**.
2. Dar click en _"Crear entorno"_.
3. Indicar _nombre_ y _descripción_.
4. En _"Tipo de entorno"_ seleccionar _"Nueva instancia de EC2"_.

   > si ya tiene una instancia configurada que desea usar deberá seleccionar _"Computación existente"_, sin embargo, esto requerirá que sepa como conectarse a su instancia mediante ssh, de ser asi pase al paso **7**.

5. En _"Tipo de instancia"_ seleccionar _"t2.micro (1 GiB RAM + 1 vCPU)"_ o el tipo de instancia **apto para la capa gratuita**, también se puede optar por elegir otro tipo según el nivel de procesamiento que necesite.
6. En _"Configuración de red"_ seleccionar _"Secure Shell (SSH)"_ [si desea abrir los puertos para conexiones remotas] o _"AWS Systems Manager (SSM)"_ [si NO desea abrir los puertos para conexiones remotas].
7. Dar click en **"Crear"**.

> El proceso de creación de la instancia Cloud9 puede llevar hasta 5 minutos.

## Crear un grupo de seguridad

1. Entrar en **"AWS VPC"**.
2. Seleccionar _"Security groups"_.
3. Identificar el grupo de seguridad asociado a tu instancia **AWS EC2** _(esta instancia es la que creamos o utilizamos al crear nuestro entorno **CLOUD9**)_, habitualmente tiene el formato _"aws-cloud-[NOMBRE_ENTORNO_CLOUD9]-[ID]"_.
4. Seleccionar la grupo de seguridad, dar click en **"Acciones"** y luego en **"Editar reglas de entrada"**.
5. En _"Tipo"_ seleccionar **"TCP Personalizado"**.
6. En \*"Intervalo de puertos" escribir **27017**.

   - El puerto 27017 es el puerto por defecto para **Amazon DocumentDB**.

7. En _"Origen"_ seleccionar _"MI IP"_, si al momento de hacer esto sale un error realizar lo siguiente:
   1. En _"Origen"_ seleccionar _"Anywhere v4-IPv4"_.
   2. En el campo a la derecha ingresar tu IP publica, puedes saber cual es tu ip publica en el siguiente enlace: https://www.whatismyip.com/ seleccionando en _"What Is My IP"_ y copia el numero en el apartado _"My Public IPv4"_. Debería quedarte algo como **xxx.xxx.xxx.xxx**, por ejemplo **168.205.10.24**
   3. Seguido de tu dirección IPv4 publica, escribe un **"/32"**. Debería quedarte algo como **"xxx.xxx.xxx.xxx/32"**, por ejemplo **168.205.10.24/32**
8. Dar click en **"Guardar regla"**.

## Saber el grupo de seguridad de un cluster en DocumentDB

1. Entrar en **"AWS DocumentDB"**.
2. Dar click sobre el cluster seleccionado.
3. Desplazarse hacia abajo, y seleccionar la pestaña _"Configuration"_.
4. Ubicar la sección _"Security and network"_ en el titulo _"Security groups"_, Estos serán todos sus grupos de seguridad.

## Añadir Grupo de seguridad a una instancia EC2

> Para que su entorno Cloud9 se conecte a DocumentDB donde tendrá almacenado su Base de datos de MongoDB deberá agregar el mismo grupo de seguridad que posee su cluster a su instancia EC2.

1. Entrar en **"AWS EC2"**.
2. Seleccionar la instancia a la que quiere modificares el grupo de seguridad.
3. Dar click en _"Acciones --> Seguridad --> Cambiar grupos de seguridad"_.
4. Desplazar hasta _"Grupos de seguridad asociados"_ y modificar los grupos de seguridad.
5. Una vez finalizado, dar click en el botón _"Guardar"_.

## Instalar MongoShell

1. Entrar en un entorno de **AWS CLOUD9**.
2. Seleccionar la instancia Cloud9 creada en el item anterior o elegir otra.
3. Una vez que le aparezca la shell del entorno Cloud9 escribir los comandos:

   `# sudo su`

   `# echo -e "[mongodb-org-4.0] \nname=MongoDB Repository\nbaseurl=https://repo.mongodb.org/yum/amazon/2013.03/mongodb-org/4.0/x86_64/\ngpgcheck=1 \nenabled=1 \ngpgkey=https://www.mongodb.org/static/pgp/server-4.0.asc" | sudo tee /etc/yum.repos.d/mongodb-org-4.0.repo`

   `# sudo yum install -y mongodb-org-shell`

- Para seccionarse de la instalación ejecutar el siguiente comando.

  `# mongo --version`

## Instalar MongoTools

1. Entrar en un entorno de **AWS CLOUD9**.
2. Una vez que le aparezca la shell del entorno Cloud9 escribir los comandos:

   `# sudo su`

   `# sudo yum install mongodb-org-tools-4.0.18`

   > Le pedirá una confirmación ingrese la _y_ en su terminal y presione enter.

## Conectar el entorno Cloud9 con el cluster en DocumentDB

1. Entrar en **"AWS DocumentDB"**.
2. Seleccionar el cluster al cual desea conectarse.
3. En el apartado _"Connectivity & security"_ en la sección _"Connect"_ encontrara las instrucciones para conectarse a su cluster.
4. Descargue el **Certificado de Autoridad (CA)** del cluster, o utilice el CA global que proporciona AWS con el siguiente comando:

   `# wget https://truststore.pki.rds.amazonaws.com/global/global-bundle.pem`

5. En la misma seccion _"Connect"_ copiar el link que aparece bajo el titulo **Connect to this cluster with the mongo shell** que debe ser algo similar a:

   `# mongo --ssl --host [CLUSTER_ENDPOINT]:[PORT] --sslCAFile global-bundle.pem --username [USERNAME] --password [PASSWORD]`

   - Como por ejemplo:

   `# mongo --ssl --host cluster_mongo_db.cluster-ctb4o38hwezr.us-east-1.docdb.amazonaws.com:27017 --sslCAFile global-bundle.pem --username facu --password facu1234`

   - Si luego de esto logra visualizar **rs0:PRIMARY>**, felicidades! se ha conectado a su **DocumentDB**.

## Comando Básicos de Mongo

- Comando para visualizar todas las bases de datos:

  `# show dbs`

- Comando para seleccionar una base de dato:

  `# use [DATABASE_NAME]`

- Para visualizar las colecciones des una base de datos:

  `# show collections`

- Para visualizar datos de una colección:

  `# db.[COLLECTION].find()`

## Generar una copia de seguridad con mongodump

1. Abrir el archivo **test-connection-to-s3.bash** y modificar las _Variables de conexión AWS S3_.
2. Abrir un entorno en **Cloud9**, el preparado en pasos anteriores para conectarnos a **DocumentDB**.
3. Ejecutar el comando:

   `# sudo su`

   `# touch test-connection-to-s3.bash`

   `# nano test-connection-to-s3.bash`

4. Dentro del editor de _NANO_ pegar el contenido del archivo **test-connection-to-s3.bash**.
5. Salir del editor _NANO_ guardando el contenido del archivo. Esto se logra apretando **CTRL+X**.
6. Correr el comando:

   `# bash test-connection-to-s3.bash`

   > Este archivo sirve para comprobar la conexión de su actual entorno **Cloud9** con **DocumentDB**.
   > Si desea ver una confirmación, notara que en su bucket S3 se subió un archivo **"test_connection_to_s3.txt"**

7. Abrir el archivo **mongodump-to-s3.bash** y modificar las _Variables de conexión DocumentDB_ y _Variables de conexión AWS S3_.

> también puede modificar el directorio temporal de respaldo

8. Dentro del entorno **Cloud9** ejecutar:

   `# touch mongodump-to-s3.bash`

   `# nano mongodump-to-s3.bash`

9. Dentro del editor de _NANO_ pegar el contenido del archivo **mongodump-to-s3.bash**.
10. Salir del editor _NANO_ guardando el contenido del archivo. Esto se logra apretando **CTRL+X**.
11. Correr el comando:

    `# bash mongodump-to-s3.bash`

> Este archivo sirve para realizar un mongodump de las bases de datos del cluster indicado y subirlas a S3

## Restaurar copia de seguridad con mongorestore

1. Abrir el archivo **mongorestore-to-s3.bash** y modificar las _Variables de conexión DocumentDB_ y _Variables de conexión AWS S3_.

> también puede modificar el directorio temporal de respaldo

2. Dentro del entorno **Cloud9** ejecutar:

   `# touch mongorestore-to-s3.bash`

   `# nano mongorestore-to-s3.bash`

3. Dentro del editor de _NANO_ pegar el contenido del archivo **mongorestore-to-s3.bash**.
4. Salir del editor _NANO_ guardando el contenido del archivo. Esto se logra apretando **CTRL+X**.
5. Correr el comando:

   `# bash mongorestore-to-s3.bash`

> Este archivo sirve para realizar un mongorestore de la ultima copia de seguridad, alojada en el bucket S3, en el cluster elegido.
