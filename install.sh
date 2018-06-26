#!/bin/bash

# /*=================================
# =            VARIABLES            =
# =================================*/
WELCOME_MESSAGE='
MMMMMMMMMMMMMMMXl..........................cXMMMMMMMMMMMMMMM
MMMMMMMMMMMMMMMK:.::....................;c.:KMMMMMMMMMMMMMMM
MMMMMMMMMMMMMMM0:.lc....................:l,;0MMMMMMMMMMMMMMM
MMMMMMMMMMMMMMMO;.l:....................;l,,OMMMMMMMMMMMMMMM
MMMMMMMMMMMMMMWx.;l;....................,l:.dWMMMMMMMMMMMMMM
MMMMMMMMMMMMMMNl.:l......................lc.lXMMMMMMMMMMMMMM
MMMMMMMMMMMMMM0;.lc......................:l,;OMMMMMMMMMMMMMM
MMMMMMMMMMMMMNd.;o;......................,l:.oNMMMMMMMMMMMMM
MMMMMMMMMMMMM0;.lc........................:l.;OMMMMMMMMMMMMM
MMMMMMMMMMMMNo.:l,.........................lc.lXMMMMMMMMMMMM
MMMMMMMMMMMWO,.lc..........................:l,,kWMMMMMMMMMMM
MMMMMMMMMMMXl.:l.....................;:::,..lc.cXMMMMMMMMMMM
MMMMMMMMMMMO,,l:..................,codxxxdc.;l;,kWMMMMMMMMMM
MMMMMMMMMMNd.:l,..,cloolc;......;ldxxxxxxxd:,lc.oNMMMMMMMMMM
MMMMMMMMMMNl.cl..lOKKKKK0Oxl;;:ldxxxxxxxxxxc.cl.cXMMMMMMMMMM
MMMMMMMMMMXl.cl.:OKKKKKKK0Oxooodxxxxxxxxxxxc.cl.cXMMMMMMMMMM
MMMMMMMMMMNd.;l,,dO0000Okdolllllodxxxxxxxxo,,l:.oNMMMMMMMMMM
MMMMMMMMMMM0:.cl.,ldddolllllllllllodxxxxxo;.cl.;OMMMMMMMMMMM
MMMMMMMMMMMWO;.cl,,:clllllllllllllllloooc,,cl,,kWMMMMMMMMMMM
MMMMMMMMMMMMW0:.:l:,,:cllllllllllllllc:,,:l:.:OWMMMMMMMMMMMM
MMMMMMMMMMMMMMXd;,:c:;,,;:cccccccc:;,,,:cc,,oKWMMMMMMMMMMMMM
MMMMMMMMMMMMMMMWKd;,:dkdl:;;;,,,;;:coxdc,;o0WMMMMMMMMMMMMMMM
MMMMMMMMMMMMMMMMMWO;.lXMWNXK00000KNWMNd.;kWMMMMMMMMMMMMMMMMM
MMMMMMMMMMMMMMMMMXo.;OWMMMMMMMMMMMMMMMKc.lXMMMMMMMMMMMMMMMMM
MMMMMMMMMMMMMMMMNo.;OWMMMMMMMMMMMMMMMMM0:.lXMMMMMMMMMMMMMMMM
MMMMMMMMMMMMMMMNd.;kWMMMMMMMMMMMMMMMMMMM0:.oNMMMMMMMMMMMMMMM
MMMMMMMMMMMMMMMK:.oNMMMMMMMMMMMMMMMMMMMMWx.;0MMMMMMMMMMMMMMM
MMMMMMMMMMMMMMMXl.:kXNWMMMMMMMMMMMMMMWWXOc.cXMMMMMMMMMMMMMMM
MMMMMMMMMMMMMMMMXx:;;:clooddddddddoolc:;;:dKWMMMMMMMMMMMMMMM
MMMMMMMMMMMMMMMMMWXOdl:;,,.........,;:cdkXWMMMMMMMMMMMMMMMMM
  ______                      _        ______                ______
 / _____)            _       | |      (____  \              (_____ \
( (____   ____ ___ _| |_ ____| |__     ____)  ) ___ _   _    _____) )___ ___
 \____ \ / ___) _ (_   _) ___)  _ \   |  __  ( / _ ( \ / )  |  ____/ ___) _ \
 _____) | (__| |_| || |( (___| | | |  | |__)  ) |_| ) X (   | |   | |  | |_| |
(______/ \____)___/  \__)____)_| |_|  |______/ \___(_/ \_)  |_|   |_|   \___/

For help, please visit box.scotch.io or scotch.io. Follow us on Twitter @scotch_io and @whatnicktweets.
'

reboot_webserver_helper() {

    sudo systemctl restart nginx

    echo 'Rebooting your webserver'
}





# /*=========================================
# =            CORE / BASE STUFF            =
# =========================================*/
sudo apt-get update

# The following is "sudo apt-get -y upgrade" without any prompts
sudo DEBIAN_FRONTEND=noninteractive apt-get -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" upgrade

sudo apt-get install -y build-essential
sudo apt-get install -y tcl
sudo apt-get install -y software-properties-common
sudo apt-get install -y python-software-properties
sudo apt-get -y install vim
sudo apt-get -y install git

# Weird Vagrant issue fix
sudo apt-get install -y ifupdown



# /*=====================================
# =            INSTALL NGINX            =
# =====================================*/

# Install Nginx
sudo add-apt-repository -y ppa:ondrej/nginx-mainline # Super Latest Version
sudo apt-get update
sudo apt-get -y install nginx
sudo systemctl enable nginx

# Remove "html" and add public
mv /var/www/html /var/www/public

# Make sure your web server knows you did this...
#MY_WEB_CONFIG='server {
#    listen 80 default_server;
#    listen [::]:80 default_server;
#
#    root /var/www/public;
#    index index.html index.htm index.nginx-debian.html;
#
#    server_name _;
#
#    location = /favicon.ico { access_log off; log_not_found off; }
#    location = /robots.txt  { access_log off; log_not_found off; }
#
#    location / {
#        try_files $uri $uri/ /index.php?$query_string;
#    }
#}'

MY_WEB_CONFIG='server {
    location / {
        proxy_pass http://localhost:8080;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header Host $host;
        proxy_cache_bypass $http_upgrade;
    }
}'

echo "$MY_WEB_CONFIG" | sudo tee /etc/nginx/sites-available/default

sudo systemctl restart nginx





# /*=============================
# =            MYSQL            =
# =============================*/
sudo debconf-set-selections <<< 'mysql-server mysql-server/root_password password root'
sudo debconf-set-selections <<< 'mysql-server mysql-server/root_password_again password root'
sudo apt-get -y install mysql-server
sudo mysqladmin -uroot -proot create scotchbox
sudo apt-get -y install php7.2-mysql
reboot_webserver_helper



# /*=============================
# =            NGROK            =
# =============================*/
sudo apt-get install ngrok-client





# /*==============================
# =            NODEJS            =
# ==============================*/
sudo apt-get -y install nodejs
sudo apt-get -y install npm

# Use NVM though to make life easy
wget -qO- https://raw.github.com/creationix/nvm/master/install.sh | bash
source ~/.nvm/nvm.sh
nvm install 8.9.4

# Node Packages
sudo npm install -g yo
sudo npm install -g pm2
sudo npm install -g webpack




# /*============================
# =            YARN            =
# ============================*/
curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add -
echo "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list
sudo apt-get update
sudo apt-get -y install yarn





# /*============================
# =            RUBY            =
# ============================*/
sudo apt-get -y install ruby
sudo apt-get -y install ruby-dev

# Use RVM though to make life easy
gpg --keyserver hkp://keys.gnupg.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3
\curl -sSL https://get.rvm.io | bash -s stable
source ~/.rvm/scripts/rvm
rvm install 2.5.0
rvm use 2.5.0








# /*=============================
# =            REDIS            =
# =============================*/
sudo apt-get -y install redis-server
sudo apt-get -y install php7.2-redis
reboot_webserver_helper






# /*==============================
# =            GOLANG            =
# ==============================*/
sudo add-apt-repository -y ppa:longsleep/golang-backports
sudo apt-get update
sudo apt-get -y install golang-go



# /*==============================
# =            ETHEREUM          =
# ==============================*/


sudo apt-get install -y software-properties-common
sudo add-apt-repository -y ppa:ethereum/ethereum
sudo apt-get update
sudo apt-get install -y ethereum
sudo apt-get install -y solc


# /*=======================================
# =            WELCOME MESSAGE            =
# =======================================*/

# Disable default messages by removing execute privilege
sudo chmod -x /etc/update-motd.d/*

# Set the new message
echo "$WELCOME_MESSAGE" | sudo tee /etc/motd





# /*===================================================
# =            FINAL GOOD MEASURE, WHY NOT            =
# ===================================================*/
sudo apt-get update
mysql -u root -proot scotchbox < /var/www/public/app/sql/init.sql
sudo DEBIAN_FRONTEND=noninteractive apt-get -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" upgrade
reboot_webserver_helper






# /*====================================
# =            YOU ARE DONE            =
# ====================================*/
echo 'Booooooooom! We are done. You are a hero. I love you.'