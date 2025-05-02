# install_nuxsaas

Install via .sh script
1. Buy and download the latest version from [https://alvinkiveu.com/script/nuxsaas-for-phpnuxbill](https://alvinkiveu.com/script/nuxsaas-for-phpnuxbill) and unzip the files.
2. Upload the zip file to your server using SFTP or SSH to the directory `/var/www/html/`

3. get the install_nuxsaas.sh script from the repository and upload it to your server using SFTP or SSH to the directory `/var/www/html/`
   - [Download install_nuxsaas.sh](https://raw.githubusercontent.com/alvin-kiveu/nuxsaas-installation-manual/main/install_nuxsaas.sh)
    - [Download nuxsaas.zip](https://raw.githubusercontent.com/alvin-kiveu/nuxsaas-installation-manual/main/nuxsaas.zip)
    - You can also use the following command to download the script directly to your server:
```bash
cd /var/www/html/
sudo wget https://raw.githubusercontent.com/alvin-kiveu/nuxsaas-installation-manual/main/install_nuxsaas.sh
```
   - Or use the following command to download the zip file directly to your server:
```bash
cd /var/www/html/

4. Change the permission of the script to make it executable:



```bash
cd /var/www/html/
sudo chmod +x install_nuxsaas.sh
```
5. Run the script:

```bash
sudo ./install_nuxsaas.sh
```
6. Follow the prompts to complete the installation.

7. After the installation is complete, you will be prompted to remove the script. Type `y` and press enter to remove the script.


8. Open your browser and visit the domain you added.

9. Fill in the installation form and click Install

10. If successful, you’ll see “Installation Successful”

11. If not, fix the displayed errors and try again

12. **Default login credentials:**

```bash
username: admin
password: admin
```
