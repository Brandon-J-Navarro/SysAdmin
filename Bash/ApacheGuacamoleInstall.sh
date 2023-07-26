# Released under MIT License

# Copyright (c) 2023 Brandon J. Navarro

# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:

# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

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
