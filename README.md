# Berryer
*Turn Raspberry PI 3 B+ in a privacy wall*

This Bash script installs and configure a copy of Docker (latest stable version) and various containers: Portainer, OpenVPN, Pihole, Motioneye to protect your network and your devices from modern privacy invasion.

To start the procedure on your Raspberry, copy berryer.sh to your device and start it typing in a Bash shell:

`$ git clone`https://github.com/riminilug/berryer`

`$ cd berryer`

`# chmod +x berryer.sh`

Then execute the script:

`# ./berryer.sh`

The procedure walks you through various choices to install all containers.

It's recomended but not necessary to get a DDNS domain before starting the procedure and to configure port forwarding on port 1194 and a static ip address for your Raspberry.

If you made mistakes it's possible to restart the procedure and skip working container's installations.

To update containers, simply restart the procedure and give the initial paramenters.

This script is preliminary.

**Hope you enjoy and contribute**


