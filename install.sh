if [ `getconf LONG_BIT` -ne "32" ]; 
then
      installpack="apache2 php5 mysql-server php5-mysql php5-gd libssh2-php openssh-server python3 screen wget unzip mc phpmyadmin ia32-libs"
else
     installpack="apache2 php5 mysql-server php5-mysql php5-gd libssh2-php openssh-server python3 screen wget unzip mc phpmyadmin"
fi
dpkg --add-architecture i386
apt-get update
export DEBIAN_FRONTEND=noninteractive;apt-get --allow-unauthenticated -y -q install $installpack
wget http://mirror.it-vps.ru/cp.zip
wget http://mirror.it-vps.ru/web.zip

rm /var/www/index.html
unzip cp.zip -d /home/
unzip web.zip -d /var/www/
rm cp.zip
rm web.zip
chmod 700 /home/cp
chmod 700 /home/cp/gameservers.py
groupadd gameservers
ln -s /usr/share/phpmyadmin /var/www/phpmyadmin


		dlinapass=10
rootmysqlpass=`base64 -w $dlinapass /dev/urandom | head -n 1`
mysqladmin -uroot password $rootmysqlpass
echo "create database game" | mysql -uroot -p$rootmysqlpass
mysql game -uroot -p$rootmysqlpass < /var/www/dump.sql

a2enmod rewrite
sed -i 's/AllowOverride None/AllowOverride All/g' /etc/apache2/sites-enabled/000-default
service apache2 restart

for i in `seq 1 100`;
do
   echo 
done
cp /var/www/application/config.default.php /var/www/application/config.php
rm /var/www/index.html

echo "INSERT INTO `game`.`users` (`user_id`, `user_email`, `user_password`, `user_firstname`, `user_lastname`, `user_status`, `user_balance`, `user_access_level`, `user_date_reg`) VALUES (NULL, 'adm@examle.com', 'e10adc3949ba59abbe56e057f20f883e', 'Администратор', 'Администратор', '1', '5000.00', '3', '2014-02-19 00:00:00');" | mysql -uroot -p$rootmysqlpass



sed -i 's/username/root/g' /var/www/application/config.php
sed -i 's/database/game/g' /var/www/application/config.php
ROOTMYSQL=$rootmysqlpass
sed -i "s/password/${ROOTMYSQL}/g" /var/www/application/config.php
IP=`ifconfig eth0 | grep "inet addr" | head -n 1 | cut -d : -f 2 | cut -d " " -f 1`
sed -i "s/url/yourdomain/${IP}/g" /var/www/application/config.php
chmod -R 777 /var/www/*

echo "Конфиг web части переписан!!!
Править его в /var/www/application/config.php
--------------------------------------------------
Данные для входа:
URL: http://$IP/
--------------------------------------------------
--------------------------------------------------
Данные mysql:
Хост: localhost
База: game
Юзер: root
Пароль: $rootmysqlpass
Данные для авторизаций:
Логин:adm@examle.com
Пароль:123456
--------------------------------------------------"