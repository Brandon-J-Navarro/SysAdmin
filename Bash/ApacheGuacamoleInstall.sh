#How to Run:
#Download file directly from here:
wget https://git.io/fxZq5 -O guac-install.sh

#Make it executable:
chmod +x guac-install.sh

#Run it as root:
# Interactive (asks for passwords):
./guac-install.sh

#Non-Interactive (values provided via cli):
./guac-install.sh --mysqlpwd [PASSWORD] --guacpwd [PASSWORD] --nomfa --installmysql
#OR
./guac-install.sh -r [PASSWORD] -gp [PASSWORD] -o -i

#Once installation is done you can access Guacamole by browsing to: http://<host_or_ip>:8080/guacamole/ The default credentials are guacadmin as both username and password. Please change them or disable guacadmin after install!
