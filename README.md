# Berryer
*Turn Raspberry PI 3 B+ in a privacy wall*

This Bash script installs and configure:

Docker [Official site](https://www.docker.com) (latest stable version) 

Docker containers:

Portainer [Official site](https://www.portainer.io/) - [container](https://hub.docker.com/r/portainer/portainer)

OpenVPN [Official site](https://openvpn.net/) - [container](https://hub.docker.com/r/giggio/openvpn-arm)

Pihole [Official site](https://pi-hole.net/)  - [container](https://hub.docker.com/r/pihole/pihole)

Motioneye [Official site](https://github.com/ccrisan/motioneye) - [container](https://hub.docker.com/r/jshridha/motioneye) 

The aim of the project is to protect your network and your devices from modern privacy invasion.

To start the procedure on your Raspberry, ensure you have a working Raspbian installation on a Raspberry PI 3 B+.
Then give the following commands:

`sudo apt install git`

`git clone https://github.com/riminilug/berryer`

`cd berryer`

`chmod +x berryer.sh`

Then execute the procedure:

`sudo ./berryer.sh`

The procedure walks you through various choices to install all containers.

It's recomended but not necessary to get a DDNS domain before starting the procedure and to configure port forwarding on port 1194 on your router and to configure a static ip address for your Raspberry.

If you made mistakes it's possible to restart the procedure and skip working container's installations.

To update containers installed with this procedure, simply run again this procedure and give the parameters given in the first installation.

The script `duckdns_configure.sh`, is the assisted procedure to configure an exixting duckdns.org domain.

`chmod +x duckdns_configure.sh`

`sudo ./duckdns_configure.sh`

These procedures are tested working on a Raspberry Pi 3B+.

These scripts are preliminary.

**Hope you enjoy and contribute**