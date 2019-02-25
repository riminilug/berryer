#!/bin/bash
#
# Description: Auto system to setup a privacy wall on Raspberry Pi with docker
#
# Copyright (C) 2019 Simone Foschi <s.foschi@gmail.com>
#

if [[ "$(id -u)" -ne 0 ]]; then
    echo "Script must be run under sudo."
    exit 1
fi

# Lookups may not work for VPN / tun0
IP_LOOKUP="$(ip route get 8.8.8.8 | awk '{for(i=1;i<=NF;i++) if ($i=="src") print $(i+1)}')"  
#IPv6_LOOKUP="$(ip -6 route get 2001:4860:4860::8888 | awk '{for(i=1;i<=NF;i++) if ($i=="src") print $(i+1)}')"  

# Just hard code these to your docker server's LAN IP if lookups aren't working
IP="${IP:-$IP_LOOKUP}"  # use $IP, if set, otherwise IP_LOOKUP
#IPv6="${IPv6:-$IPv6_LOOKUP}"  # use $IPv6, if set, otherwise IP_LOOKUP

read -p 'do you have an available domain, a static ip address on Raspberry and configured port forwarding of port 1194 on the router? [y/n]: ' NETWORK_CONFIGURATION_AVAILABLE
if [ $NETWORK_CONFIGURATION_AVAILABLE == 'Y' ] || [ $NETWORK_CONFIGURATION_AVAILABLE == 'y' ]
then
    read -p 'do you want to install Docker? [y/n]: ' DOCKER
    if [ $DOCKER == 'Y' ] || [ $DOCKER == 'y' ]
    then
        #check if docker is installed, if yes skip otherwise this script installs it
        #if [ -x !"$(command -v docker)" ]
        #then
            echo "Installing Docker..."
            curl -sSL https://get.docker.com | sh
            echo "Docker will be configured for user pi"
            echo "To use it with another account, on command line digit-->"
            echo "sudo usermod -aG docker YOURUSER"
            usermod -aG docker pi
            echo "Docker installed and configured for user pi, logout and login to apply changes"
        #else
        #    echo "Docker is already installed"
        #fi
    fi

    read -p "do you want to install Portainer? [y/n]: " PORTAINER

    if [ $PORTAINER == 'Y' ] || [ $PORTAINER == 'y' ]
    then
        echo "Installing Portainer..."
        #try to remove exixting installation then create or update che container
        docker rm -f portainer 2>/dev/null
        docker pull portainer/portainer
        docker volume create portainer_data
        docker run -d -p 9000:9000 --name portainer -v /var/run/docker.sock:/var/run/docker.sock -v portainer_data:/data portainer/portainer

        echo "Portainer is active on port 9000"
        echo "to see it: http://localhost:9000"
        echo "or: http://${IP}:9000"
    fi

    
    read -p "do you want to install OpenVPN? [y/n]: " OPENVPN

    if [ $OPENVPN == 'Y' ] || [ $OPENVPN == 'y' ]
    then
        echo "Installing OpenVPN..."

        read -p "Insert your domain name. Example: my-sub-domain.duckdns.org and press [enter]: " DOMAIN

        read -p "Insert the name of the client you wish to enable OpenVPN in and press [enter]: " CLIENT_NAME

        OVPN_DATA="ovpn-data-privacybox"
        docker rm -f openvpn  2>/dev/null
        docker pull giggio/openvpn-arm
        docker run -v $OVPN_DATA:/etc/openvpn --rm giggio/openvpn-arm ovpn_genconfig -u udp://$DOMAIN
        docker run -v $OVPN_DATA:/etc/openvpn --rm -it giggio/openvpn-arm ovpn_initpki
        docker run -v $OVPN_DATA:/etc/openvpn -d -p 1194:1194/udp --name openvpn --cap-add=NET_ADMIN --restart=unless-stopped giggio/openvpn-arm
        docker run -v $OVPN_DATA:/etc/openvpn --log-driver=none --rm -it giggio/openvpn-arm easyrsa build-client-full $CLIENT_NAME nopass
        docker run -v $OVPN_DATA:/etc/openvpn --log-driver=none --rm giggio/openvpn-arm ovpn_getclient $CLIENT_NAME > $HOME/$CLIENT_NAME.ovpn

        echo "Certificate for the client saved in $HOME/${CLIENT_NAME}.ovpn"
        echo "OpenVPN installed"
        echo ""
        echo "Use the following commands to generate other certificates. Substitute CLIENT_NAME with the desired cert name"
        echo "docker run -v ${OVPN_DATA}:/etc/openvpn --log-driver=none --rm -it giggio/openvpn-arm easyrsa build-client-full CLIENT_NAME nopass"
        echo "docker run -v ${OVPN_DATA}:/etc/openvpn --log-driver=none --rm giggio/openvpn-arm ovpn_getclient CLIENT_NAME > CLIENT_NAME.ovpn"
    fi


    read -p "do you want to install Pihole? [y/n]: " PIHOLE

    if [ $PIHOLE == 'Y' ] || [ $PIHOLE == 'y' ]
    then
        echo "Installing Pihole..."
        #read -sp "Insert password for Pihole admin: " PASSWORD


        # Default of directory you run this from, update to where ever.
        DOCKER_CONFIGS=$HOME

        echo "### Make sure your IPs are correct, hard code ServerIP ENV VARs if necessary\nIP: ${IP}"
        docker rm -f pihole 2>/dev/null
        docker pull pihole/pihole:latest
        # Default ports + daemonized docker container
        docker run -d \
            --name pihole \
            -p 53:53/tcp -p 53:53/udp \
            -p 67:67/udp \
            -p 80:80 \
            -p 443:443 \
            -v "${DOCKER_CONFIGS}/pihole/:/etc/pihole/" \
            -v "${DOCKER_CONFIGS}/dnsmasq.d/:/etc/dnsmasq.d/" \
            -e ServerIP="${IP}" \
            -e TZ="$(cat /etc/timezone)" \
            --restart unless-stopped \
            --cap-add=NET_ADMIN \
            --dns=127.0.0.1 --dns=1.1.1.1 \
            pihole/pihole:latest

        echo "Pihole administration visible at http://pi.hole/admin"
        echo "or http://${IP}/admin"
        echo "Your password is " docker logs pihole 2> /dev/null | grep 'random'
        echo ""
    fi

    read -p "do you want to install Motioneye? [y/n]: " MOTONEYE

    if [ $MOTONEYE == 'Y' ] || [ $MOTONEYE == 'y' ]
    then
        echo "Installing Motioneye..."
        echo "https://hub.docker.com/r/jshridha/motioneye"

        docker rm -f motioneye 2>/dev/null
        docker pull jshridha/motioneye:latest
        docker run -d --name=motioneye \
            -p 8081:8081 \
            -p 8765:8765 \
            -e TIMEZONE="$(cat /etc/timezone)" \
            -e PUID="99" \
            -e PGID="100" \
            --restart unless-stopped \
            -v /mnt/user/appdata/motioneye/media:/home/nobody/media \
            -v /mnt/user/appdata/motioneye/config:/config \
            vividboarder/rpi-motioneye

        echo "Motioneye installed and visible at"
        echo "http://${IP}:8765"
        
    fi
fi