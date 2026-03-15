### OS: Bullseye
* https://raspberrytips.com/install-raspbian-raspberry-pi/
* https://www.raspberrypi.com/news/raspberry-pi-os-debian-bullseye/

### documentation
https://www.raspberrypi.com/documentation/


## disk speed tests
* https://webhostinggeeks.com/howto/how-to-check-disk-read-write-speed-in-linux/
* https://www.cyberciti.biz/faq/howto-linux-unix-test-disk-performance-with-dd-command/
```text
fio:     
dd:      
hdparm:  
```



### focus follows mouse
https://forums.raspberrypi.com/viewtopic.php?t=240999
```text
obconf
```


### SSH enable
https://phoenixnap.com/kb/enable-ssh-raspberry-pi
```text

# TUI:
sudo raspi-config

# CLI:
sudo systemctl enable ssh
sudo systemctl start ssh

# identify host
hostname -l
ip a

```






# LAMP phpMyAdmin
https://randomnerdtutorials.com/raspberry-pi-apache-mysql-php-lamp-server/

sudo apt install apache2 php mariadb-server php-mysql
sudo mysql_secure_installation
sudo apt install phpmyadmin
sudo phpenmod mysqli
sudo service apache2 restart
open http://localhost               => apache2 config page
open http://localhost/phpmyadmin    => root/root

# SQL CLI
sudo mysql -u root
CREATE USER rafael identified by 'root';


# PHP-SQL Configs:
hostname -I
/var/www/html
/etc/dbconfig-common/phpmyadmin.conf
/etc/php/7.4/mods-available/mbstring.ini

$ ls -lh /var/www/
$ sudo chown -R pi:www-data /var/www/html/
$ sudo chmod -R 770 /var/www/html/
$ ls -lh /var/www/
