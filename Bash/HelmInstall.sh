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

#Prerequisites
#A Kubernetes cluster
#Deciding what security configurations to apply to your installation, if any
#Installing and configuring Helm.

#Installing Helm
curl https://baltocdn.com/helm/signing.asc | gpg --dearmor | sudo tee /usr/share/keyrings/helm.gpg > /dev/null
sudo apt-get install apt-transport-https --yes
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/helm.gpg] https://baltocdn.com/helm/stable/debian/ all main" | sudo tee /etc/apt/sources.list.d/helm-stable-debian.list
sudo apt-get update
sudo apt-get install helm

#Initialize a Helm Chart Repository
#Once you have Helm ready, you can add a chart repository. Check Artifact Hub for available Helm chart repositories.
helm repo add bitnami https://charts.bitnami.com/bitnami
helm search repo bitnami

#Install an Example Chart
#To install a chart, you can run the helm install command. Helm has several ways to find and install a chart, but the easiest is to use the bitnami charts.
helm repo update              # Make sure we get the latest list of charts
helm install bitnami/mysql --generate-name

#Learn About Releases
helm list

#Uninstall a Release
#To uninstall a release, use the helm uninstall command:
helm uninstall 
