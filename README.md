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
6. Repositorio de GitHub

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

**`setup_loadbalancer.sh`**  
```bash
#!/bin/bash
# Instalar HAProxy
sudo apt update
sudo apt install -y haproxy

# Configuración de HAProxy
sudo tee /etc/haproxy/haproxy.cfg > /dev/null <<EOL
frontend http_front
    bind *:80
    default_backend web_servers

backend web_servers
    balance roundrobin
    server web1 <IP_WEB1>:80 check
    server web2 <IP_WEB2>:80 check
EOL

# Reiniciar servicio
sudo systemctl restart haproxy


Configuración de un directorio compartido para que los servidores web accedan a contenido estático.
Servidor MySQL:

Instalación y configuración de MySQL.
Creación de una base de datos y usuario para WordPress.
