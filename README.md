# **Carlos Castillo González    ASIR 2**
# **Implementación de WordPress en Arquitectura de Tres Niveles**
Este proyecto detalla la implementación de un entorno **WordPress escalable** utilizando una arquitectura de tres niveles en **AWS**. La infraestructura incluye un balanceador de carga (HAProxy), servidores web (Apache), un servidor de base de datos (MySQL) y un servidor NFS para compartir contenido estático.

---

## **Tabla de Contenidos**
1. Descripción del Proyecto
2. Infraestructura
3. Requisitos Previos
4. Pasos de Implementación
   - Creación de las Instancias
   - Configuración de los Grupos de Seguridad
5. Scripts de Aprovisionamiento
   - Balanceador de Carga
   - Servidores Web
   - Servidor NFS
   - Servidor MySQL
6. Configuración BD y comprobación

---

## **Descripción del Proyecto**

Este proyecto implementa **WordPress** en una arquitectura de tres niveles sobre **AWS**, proporcionando escalabilidad y alta disponibilidad. Los componentes principales son:

- **Balanceador de carga (HAProxy)**: Redistribuye el tráfico entrante entre los servidores web.
- **Servidores web (Apache)**: Sirven la aplicación WordPress.
- **Servidor NFS**: Comparte contenido estático entre los servidores web.
- **Servidor MySQL**: Aloja la base de datos de WordPress.

---

## **Infraestructura**

El entorno incluye las siguientes máquinas, creadas manualmente desde la consola de AWS:

| **Nombre**         | **Función**            | **AMI**              | **Tipo de Instancia** | **Grupo de Seguridad**       |
|--------------------|------------------------|----------------------|-----------------------|------------------------------|
| **Balanceador**    | HAProxy                | Ubuntu 20.04         | t2.micro              | Balanceador                  |
| **Web 1**          | Apache + WordPress     | Ubuntu 20.04         | t2.micro              | Servidores Web               |
| **Web 2**          | Apache + WordPress     | Ubuntu 20.04         | t2.micro              | Servidores Web               |
| **NFS**            | Compartir contenido    | Ubuntu 20.04         | t2.micro              | Servidor NFS                 |
| **Base de Datos**  | MySQL                  | Ubuntu 20.04         | t2.micro              | Servidor de Base de Datos    |

---

## **Requisitos Previos**

1. **Cuenta AWS**: Configurar el CLI de AWS si necesitas administrar recursos.
2. **Conexión SSH**: Asegúrate de tener las claves privadas para acceder a las instancias.

---

## **Pasos de Implementación**

### **1. Creación de las Instancias**

Las instancias se crearon manualmente desde la consola de AWS:
1. Ve a **EC2 > Lanzar Instancia**.
2. Selecciona la AMI de **Ubuntu Server 20.04 LTS**.
3. Configura el tipo de instancia como **t2.micro**.
4. Asocia cada instancia con su grupo de seguridad correspondiente.
5. Lanza las instancias y conéctate a través de SSH para su configuración.

6. Aquí un ejemplo de como he lanzado una:
   
![image](https://github.com/user-attachments/assets/e83ee6e6-c35e-412f-b618-615c89e611fc)
![image](https://github.com/user-attachments/assets/57398614-65ea-4615-b862-86685eca4562)
![image](https://github.com/user-attachments/assets/48435c22-5f62-481e-b5be-d4c8c8ae0f25)
![image](https://github.com/user-attachments/assets/0a2ae653-d89a-45e8-859a-5de350d7e28a)
![image](https://github.com/user-attachments/assets/8c8f4195-831c-40d3-b6b0-b6fece9d909c)
![image](https://github.com/user-attachments/assets/b942aad9-9416-41f2-b205-4ab49de2001c)
![image](https://github.com/user-attachments/assets/3f163dd4-2ddc-4825-b7fc-59c9ff473980)

---

### **2. Configuración de los Grupos de Seguridad**
![image](https://github.com/user-attachments/assets/ca1f8515-5d1a-47e8-a1d2-0e205ced9524)


Define reglas específicas para cada grupo de seguridad:

| **Grupo de Seguridad** | **Puerto** | **Protocolo** | **Origen/Destino**          | **Descripción**                   |
|------------------------|------------|---------------|-----------------------------|-----------------------------------|
| **Balanceador**        | 80         | TCP           | 0.0.0.0/0                   | Permitir tráfico HTTP público.    |
|                        | 443        | TCP           | 0.0.0.0/0                   | Permitir tráfico HTTPS público.   |
| **Servidores Web**     | 80         | TCP           | Grupo del Balanceador       | Tráfico HTTP desde el balanceador.|
|                        | 2049       | TCP           | Grupo del Servidor NFS      | Comunicación con el servidor NFS. |
| **Servidor NFS**       | 2049       | TCP           | Grupo de Servidores Web     | Compartir archivos.               |
| **Base de Datos**      | 3306       | TCP           | Grupo de Servidores Web     | Tráfico MySQL desde servidores.   |

---

## **Scripts de Aprovisionamiento**

### **Balanceador de Carga**  
```bash
apt update -y
apt install -y apache2
a2enmod proxy
a2enmod proxy_http
a2enmod proxy_balancer
a2enmod lbmethod_byrequests
cp /etc/apache2/sites-available/000-default.conf /etc/apache2/sites-available/load-balancer.conf
sed -i '/DocumentRoot \/var\/www\/html/s/^/#/' /etc/apache2/sites-available/load-balancer.conf
sed -i '/:warn/ a \<Proxy balancer://mycluster>\n    # Server 1\n    BalancerMember http://192.168.10.135\n    # Server 2\n    BalancerMember http://192.168.10.140\n</Proxy>\n#todas las peticiones las envÃa al siguiente balanceador\nProxyPass / balancer://mycluster/' /etc/apache2/sites-available/load-balancer.conf
a2ensite load-balancer.conf
a2dissite 000-default.conf
systemctl restart apache2
systemctl reload apache2
```
### **NFS**
```bash
apt update -y
apt install nfs-kernel-server -y
apt install unzip -y
apt install curl -y
apt install php php-mysql -y
apt install mysql-client -y

mkdir /var/nfs/shared -p
chown -R nobody:nogroup /var/nfs/shared
sed -i '$a /var/nfs/shared    192.168.10.135(rw,sync,no_subtree_check)' /etc/exports
sed -i '$a /var/nfs/shared    192.168.10.140(rw,sync,no_subtree_check)' /etc/exports
curl -O https://wordpress.org/latest.zip
unzip -o latest.zip -d /var/nfs/shared/
chmod 755 -R /var/nfs/shared/
chown -R www-data:www-data /var/nfs/shared/*
systemctl restart nfs-kernel-server
```
### **WebServers**
```bash
apt update -y
apt install apache2 -y
apt install nfs-common -y
apt install php libapache2-mod-php php-mysql php-curl php-gd php-xml php-mbstring php-xmlrpc php-zip php-soap php -y
a2enmod rewrite
#servidores web
sudo sed -i 's|DocumentRoot .*|DocumentRoot /nfs/shared/wordpress|g' /etc/apache2/sites-available/000-default.conf

sed -i '/<\/VirtualHost>/i \
<Directory /nfs/shared/wordpress>\
    Options Indexes FollowSymLinks\
    AllowOverride All\
    Require all granted\
</Directory>' /etc/apache2/sites-available/000-default.conf


cp /etc/apache2/sites-available/000-default.conf /etc/apache2/sites-available/websv.conf
# Montar la carpeta compartida desde el servidor NFS

mkdir -p /nfs/shared
mount 192.168.10.134:/var/nfs/shared /nfs/shared
a2dissite 000-default.conf
a2ensite websv.conf
echo "192.168.10.134:/var/nfs/general /nfs/general nfs auto,nofail,noatime,nolock,intr,tcp,actimeo=1800 0 0" | sudo tee -a /etc/fstab
mount -a 
systemctl restart apache2
systemctl reload apache2
systemctl status apache2
```
### **SGBD**
```bash
apt install mysql-server -y
apt update -y
apt install -y mysql-server
sudo apt install -y phpmyadmin
sed -i "s/^bind-address\s*=.*/bind-address = 192.168.10.153/" /etc/mysql/mysql.conf.d/mysqld.cnf
sudo systemctl restart mysql

 mysql <<EOF
CREATE DATABASE db_wordpress;
CREATE USER 'Carloscast'@'192.168.10.%' IDENTIFIED BY 'S1234?';
GRANT ALL PRIVILEGES ON db_wordpress.* TO 'Carloscast'@'192.168.10.%';
FLUSH PRIVILEGES;
EOF
```
### Una vez ejecutados todos los SH, nos vamos a la página wordpress con nuestra IP pública, para empezar a realizar la configuración de la base de datos:

# Creación de una base de datos y usuario para WordPress:
![image](https://github.com/user-attachments/assets/cb2334dd-6312-4293-bf8c-33f3bc1a7d18)
![image](https://github.com/user-attachments/assets/01ddd632-1a67-47e1-bebc-b0a4703ddf72)
![image](https://github.com/user-attachments/assets/6d612d30-931d-4146-af19-8b43178c3ae3)

# Una vez configurada la base de datos, podremos acceder a wordpress:
![image](https://github.com/user-attachments/assets/bad2c05e-696c-4392-bed7-22bfe4c3f36b)

## Realizarlo como sitio seguro:
# Para ello, tendremos que registrar un dominio y asociarlo a la IP eláctica:
![image](https://github.com/user-attachments/assets/4ecf5f78-f596-4512-905d-82e617ffe23a)

# Después, nos dirigimos al balanceador, e instalamos Certbot:
![image](https://github.com/user-attachments/assets/2168d2d8-d86e-4989-859e-cc103fd374b5)

# Después, ejecutamos certbot:
![image](https://github.com/user-attachments/assets/119cea55-e61e-4012-a8f4-750b980d77d3)

# Y por último, comprobamos con el nombre del dominio 
![image](https://github.com/user-attachments/assets/a9010663-ccda-4bc5-9226-990f1aaf4002)

## **Conclusión**

Este proyecto permite crear un sitio WordPress en una arquitectura de tres niveles utilizando AWS. Hemos a configurado diferentes componentes como el balanceador de carga, los servidores web, el servidor de base de datos y un sistema de archivos compartido con NFS. Aunque hubo algunos desafíos, como problemas con el montaje automático de NFS y la optimización del rendimiento, logramos resolverlos y entender mejor cómo funcionan estas tecnologías juntas.

Al final, conseguimos que WordPress funcione de forma estable y con una estructura escalable. Este trabajo nos ayudó a practicar habilidades importantes como configurar servicios en la nube, solucionar problemas técnicos y optimizar sistemas para que sean más rápidos y confiables. Este proyecto es una buena base para seguir aprendiendo más sobre arquitectura de servidores y aplicaciones web.

