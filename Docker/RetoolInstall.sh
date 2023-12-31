# Deploy Retool on a local machine
# Follow the instructions in this guide to deploy self-hosted Retool on your local machine.

# CAUTION
# If possible, you should deploy Retool on a virtual machine such as AWS EC2, Azure VM, or GCP Compute Engine. VM hardware and operating systems are more standardized than physical machines, so they are more robust for production deployments. If you need to deploy on a physical machine, verify it meets the minimum network and storage requirements.

# Requirements
# To deploy Retool on your local machine, you need:

# A Retool license key, which you can obtain from my.retool.com or your Retool account manager.
# A working installation of Docker desktop.
# 1. Install Retool

# Download the retool-on-premise repository and change your working directory to retool.
curl -L -O https://github.com/tryretool/retool-onpremise/archive/master.zip && unzip master.zip
cd retool-onpremise-master

# Run the docker_setup script to create a docker.env file.
./docker_setup

# 2. Update environment variables
# On Docker deployments, environment variables are set in docker.env.

# In docker.env, set 
LICENSE_KEY="to your license key"

# In docker.env, uncomment the 
COOKIE_INSECURE=true

# After you set up SSL, you should set 
COOKIE_INSECURE=false

# Copy the ENCRYPTION_KEY in docker.env generated by the install script. Save this key in a secure location outside of Retool. This key encrypts secrets for your Retool resources.

# 3. Set the version and start Retool
# In your Dockerfile, replace X.Y.Z with a Retool version tag, for example 2.116.3. Identify the appropriate release version by viewing the tags on Docker Hub. See Retool's self-hosted release notes to learn about version-specific features.

# Start Retool. It may take a few minutes to pull the images and start each service.

sudo docker-compose up -d

# Confirm the containers are running.
sudo docker-compose ps

# Self-hosted Retool is now running. Go to http://0.0.0.0:3000/ to create your Retool admin account.

# Additional steps
# Use these steps to keep your local instance up-to-date.

# Update Retool
# Update your Dockerfile with the newer version number.
# FROM tryretool/backend:X.Y.Z

# Install the upgrade.
./update_retool.sh

# Retool instances temporarily go down while they upgrade. You can check the status of your containers with sudo docker-compose ps.
