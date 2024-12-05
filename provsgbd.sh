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