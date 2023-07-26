# Run the easy install script
# Run this script to create Retool at ~/retool/retool-onpremise and run the docker containers.

/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/tryretool/retool-onpremise/ssop/deploy-retool)" < <(echo "[LICENSEKEY]")

# Connect to Retool
# That's it! Retool is now running at [yourIpAddress]:3000. You can open this page in your browser then click sign up.
