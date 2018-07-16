#!/bin/bash

# creditials
username = YOUR_USERNAME
password = YOUR_PASSWORD

# capturer network definition
PCnet16 = Summer
PCnet17 = Autumn
PCnet18 = May
PCnet19 = October
capture_servers = ($Summer $Autumn $May $October)

# receiver network definition
MCR1net16 = Fall
MCR1net17 = November
MCR2net17 = Spring
MCR1net18 = July
MCR1net19 = Solstice
receive_servers = ($Fall $November $Spring $July $Solstice)

# sender network definition
MCSnet16 = April
MCSnet17 = August
MCSnet18 = Winter
MCSnet19 = Year
send_servers = ($April $August $Winter $Year)

# multicast group definition
MIP = 225.128.127.4
MPORT = 3748

HOST_DIR = "$(whoami)@$(hostname):$PWD"

# start capturing packets
for server in $capture_servers; do
  ssh -Y $username@$server -p "$password" "tshark -w ~/$server-eth1.pcap -i eth1"
done

sleep 10

# join multicast groups
for server in $receive_servers; do
  ssh -Y $username@$server -p "$password" << EOF
ip maddr add $MIP
mgen event "listen UDP $MPORT" &
EOF
done

sleep 60

# start sending packets
for server in $send_servers; do
  ssh -Y $username@$server -p "$password" "mgen event \"0.0 on 1 UDP DST $MIP/$MPORT periodic [0.5 500] \" &"
done

sleep 60

#  stop sending packets
for server in $send_servers; do
  ssh -Y $username@$server -p "$password" "killall mgen"
done

sleep 60

# exit multicast groups
for server in $receive_servers; do
  ssh -Y $username@$server -p "$password" << EOF
killall mgen
ip maddr del $MIP
EOF
done

sleep 60

# stop capturing packets and collect results
for server in $capture_servers; do
  ssh -Y $username@$server -p "$password" << EOF
killall tshark
scp ~/*.pcap $HOST_DIR
EOF
done