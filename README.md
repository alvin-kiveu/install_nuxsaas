# install_nuxsaas


1. Download the latest NuxSaas version
---------------------------------------
Visit the official link and buy/download the latest NuxSaas build:

https://alvinkiveu.com/script/nuxsaas-for-phpnuxbill

2. Upload Files to Your Server
------------------------------
Use SFTP or SSH to upload the downloaded ZIP file to your server:
Target directory: /var/www/html/

Alternatively, download the zip directly via wget:
```bash
cd /var/www/html/
sudo wget https://raw.githubusercontent.com/alvin-kiveu/install_nuxsaas/main/nuxsaas.zip
```

3. Download and Prepare the Installer Script
--------------------------------------------

Download the installer script from the official GitHub repo:

Option 1: Manual Upload via SFTP/SSH  

Upload `install_nuxsaas.sh` to `/var/www/html/`

Option 2: Download with wget:

install wget if not already installed:

```bash
sudo apt install wget
```

Then download the script directly to your server:

```bash
cd /var/www/html/
sudo wget https://raw.githubusercontent.com/alvin-kiveu/install_nuxsaas/main/install_nuxsaas.sh
```

Make the script executable:
```bash
sudo chmod +x install_nuxsaas.sh
```

4. Run the Installer
--------------------
Execute the script:
```bash
sudo ./install_nuxsaas.sh
```

Follow the on-screen prompts to:

- Choose between Apache or Nginx
- Set your domain name
- Complete installation and Apache/Nginx setup

5. Cleanup
----------

After installation, you will be prompted to delete the script.
Type 'y' and press Enter when asked to remove `install_nuxsaas.sh`.

6. Finalize via Browser
-----------------------
Open your browser and go to the domain you added.

Complete the web installer form and click "Install".

7. Done!
--------
If successful: You'll see “Installation Successful”
If not: Fix any displayed errors and try again.

Default Login Credentials:
--------------------------
    Username: admin
    Password: admin
