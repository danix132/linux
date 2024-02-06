#!/bin/bash

# Solicitar al usuario la dirección IP y la máscara de red para la interfaz
read -p "Ingresa la dirección IP para la interfaz de red (ejemplo 192.168.1.1): " ip_address
read -p "Ingresa la máscara de red para la interfaz de red (ejemplo 255.255.255.0): " subnet_mask

# Solicitar al usuario el rango de direcciones IP para el servidor DHCP
read -p "Ingresa el rango de direcciones IP para el servidor DHCP (ejemplo 192.168.1.100 192.168.1.200): " ip_range

# Instalar paquetes necesarios
sudo apt update
sudo apt install -y isc-dhcp-server

# Configurar la interfaz de red
cat << EOF | sudo tee /etc/netplan/01-netcfg.yaml
network:
  version: 2
  renderer: networkd
  ethernets:
    eth0:
      addresses: [$ip_address/$subnet_mask]
EOF

sudo netplan apply

# Configurar el servidor DHCP
cat << EOF | sudo tee /etc/dhcp/dhcpd.conf
subnet $ip_address netmask $subnet_mask {
  range $ip_range;
  option routers $ip_address;
  option domain-name-servers 8.8.8.8, 8.8.4.4;
}
EOF

# Configurar la interfaz de red para el servidor DHCP
sudo sed -i 's/INTERFACESv4=""/INTERFACESv4="eth0"/' /etc/default/isc-dhcp-server

# Reiniciar el servicio DHCP
sudo systemctl restart isc-dhcp-server