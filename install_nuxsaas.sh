#!/bin/bash

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No color

echo -e "${GREEN}--- NuxSaas Auto Installer ---${NC}"

# Prompt user inputs
read -p "Enter your domain (e.g., example.com): " DOMAIN
read -p "Enter your email address for server admin: " EMAIL
read -p "Enter the full URL to the NuxSaas zip file: " ZIP_URL

# Sanity check for missing input
if [[ -z "$DOMAIN" || -z "$EMAIL" || -z "$ZIP_URL" ]]; then
  echo -e "${RED}Missing input. Please provide all required information.${NC}"
  exit 1
fi

# Check if DOMAIN is valid
if ! [[ "$DOMAIN" =~ ^[a-zA-Z0-9.-]+$ ]]; then
  echo -e "${RED}Invalid domain format. Please enter a valid domain.${NC}"
  exit 1
fi

# Check if EMAIL is valid
if ! [[ "$EMAIL" =~ ^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$ ]]; then
  echo -e "${RED}Invalid email format. Please enter a valid email address.${NC}"
  exit 1
fi

# Check if ZIP_URL is valid
if ! curl --output /dev/null --silent --head --fail "$ZIP_URL"; then
  echo -e "${RED}Invalid ZIP URL. Please check the URL and try again.${NC}"
  exit 1
fi

# Check if running as root
if [ "$EUID" -ne 0 ]; then
  echo -e "${RED}Please run as root.${NC}"
  exit 1
fi

# Check if the script is run on Ubuntu
if [[ $(lsb_release -is) != "Ubuntu" ]]; then
  echo -e "${RED}This script is designed for Ubuntu only.${NC}"
  exit 1
fi

echo -e "${GREEN}Checking for required packages...${NC}"
# Update packages
sudo apt update -y || { echo -e "${RED}Failed to update packages.${NC}"; exit 1; }

# Check if PHP is installed
if ! command -v php &> /dev/null; then
  echo -e "${RED}PHP is not installed. Installing PHP...${NC}"
  sudo apt install php -y || { echo -e "${RED}Failed to install PHP.${NC}"; exit 1; }
else
  echo -e "${GREEN}PHP is already installed.${NC}"
fi

# Check if unzip is installed
if ! command -v unzip &> /dev/null; then
  echo -e "${RED}Unzip is not installed. Installing Unzip...${NC}"
  sudo apt install unzip -y || { echo -e "${RED}Failed to install Unzip.${NC}"; exit 1; }
else
  echo -e "${GREEN}Unzip is already installed.${NC}"
fi

# Check if MySQL is installed
if ! command -v mysql &> /dev/null; then
  echo -e "${RED}MySQL is not installed. Installing MySQL...${NC}"
  sudo apt install mysql-server -y || { echo -e "${RED}Failed to install MySQL.${NC}"; exit 1; }
else
  echo -e "${GREEN}MySQL is already installed.${NC}"
fi

# Detect server type automatically
if command -v apache2 &> /dev/null; then
  SERVER="apache"
  echo -e "${GREEN}Apache server detected.${NC}"
elif command -v nginx &> /dev/null; then
  SERVER="nginx"
  echo -e "${GREEN}NGINX server detected.${NC}"
else
  echo -e "${RED}No supported web server found. Please install Apache or NGINX.${NC}"
  exit 1
fi

# Prepare directory
sudo mkdir -p /var/www/html/nuxsaas || { echo -e "${RED}Failed to create directory.${NC}"; exit 1; }
cd /var/www/html || { echo -e "${RED}Failed to change to /var/www/html directory.${NC}"; exit 1; }

# Download ZIP
echo -e "${GREEN}Downloading NuxSaas...${NC}"
sudo wget -O nuxsaas.zip "$ZIP_URL" || { echo -e "${RED}Failed to download NuxSaas.${NC}"; exit 1; }

# Extract and set permissions
echo -e "${GREEN}Extracting files...${NC}"
sudo unzip -o nuxsaas.zip -d nuxsaas || { echo -e "${RED}Failed to extract NuxSaas files.${NC}"; exit 1; }
sudo chown -R www-data:www-data /var/www/html/nuxsaas || { echo -e "${RED}Failed to set ownership for NuxSaas files.${NC}"; exit 1; }
sudo chmod -R 755 /var/www/html/nuxsaas || { echo -e "${RED}Failed to set permissions for NuxSaas files.${NC}"; exit 1; }

# Apache setup
if [[ "$SERVER" == "apache" ]]; then
  echo -e "${GREEN}Setting up Apache config...${NC}"
  APACHE_CONF="/etc/apache2/sites-available/nuxsaas.conf"
  sudo bash -c "cat > $APACHE_CONF" <<EOL
<VirtualHost *:80>
    ServerName $DOMAIN
    ServerAdmin $EMAIL
    DocumentRoot /var/www/html/nuxsaas

    <Directory /var/www/html/nuxsaas/>
        Options Indexes FollowSymLinks
        AllowOverride All
        Require all granted
    </Directory>

    ErrorLog \${APACHE_LOG_DIR}/error.log
    CustomLog \${APACHE_LOG_DIR}/access.log combined

    <IfModule mod_dir.c>
        DirectoryIndex index.html index.php
    </IfModule>
</VirtualHost>
EOL
  sudo a2ensite nuxsaas.conf || { echo -e "${RED}Failed to enable Apache site.${NC}"; exit 1; }
  sudo a2enmod rewrite || { echo -e "${RED}Failed to enable Apache mod_rewrite.${NC}"; exit 1; }
  sudo systemctl reload apache2 || { echo -e "${RED}Failed to reload Apache.${NC}"; exit 1; }
  sudo apache2ctl configtest || { echo -e "${RED}Apache configuration test failed.${NC}"; exit 1; }

# NGINX setup
elif [[ "$SERVER" == "nginx" ]]; then
  echo -e "${GREEN}Setting up NGINX config...${NC}"
    PHP_VERSION=$(php -r "echo PHP_MAJOR_VERSION.'.'.PHP_MINOR_VERSION;")
    PHP_FPM_SOCK="/run/php/php${PHP_VERSION}-fpm.sock"

    # Validate that PHP-FPM socket exists
    if [ ! -e "$PHP_FPM_SOCK" ]; then
    echo -e "${RED}PHP-FPM socket not found at $PHP_FPM_SOCK. Is PHP-FPM installed and running?${NC}"
    exit 1
    fi

  NGINX_CONF="/etc/nginx/sites-available/nuxsaas"
  sudo bash -c "cat > $NGINX_CONF" <<EOL
server {
    listen 80;
    server_name $DOMAIN;

    root /var/www/html/nuxsaas;
    index index.php index.html index.htm;

    location / {
        try_files \$uri \$uri/ =404;
    }

    location ~ \.php$ {
        include snippets/fastcgi-php.conf;
        fastcgi_pass unix:$PHP_FPM_SOCK;
        fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;
        include fastcgi_params;
    }

    location ~ /\.ht {
        deny all;
    }
}
EOL
  sudo ln -s $NGINX_CONF /etc/nginx/sites-enabled/ || { echo -e "${RED}Failed to enable NGINX site.${NC}"; exit 1; }
  sudo systemctl reload nginx || { echo -e "${RED}Failed to reload NGINX.${NC}"; exit 1; }
fi

echo -e "${GREEN}✔️ Installation complete. Visit http://$DOMAIN to continue setup in browser
Login with the following credentials:
Username: admin
Password: admin
Please change the password after first login.${NC}"
echo -e "${YELLOW}Note: Make sure to set up SSL for your domain. You can use Let's Encrypt for free SSL certificates.${NC}"
echo -e "${BLUE}For further assistance, Call/Whatsapp: +254 113 015 674
Email: alvo967@gmail.com
Website: https://www.alvinkiveu.com
${NC}"
