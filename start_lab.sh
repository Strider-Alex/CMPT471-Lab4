#!/bin/bash

# host info
username=$(whoami)
HOST_DIR="$(whoami)@$(hostname):$PWD"

# capturer network definition
PCnet16=Summer
PCnet17=Autumn
PCnet18=May
PCnet19=October
capture_servers=($PCnet16 $PCnet17 $PCnet18 $PCnet19)

# receiver network definition
MCR1net16=Fall
MCR1net17=November
MCR2net17=Spring
MCR1net18=July
MCR1net19=Solstice
receive_servers=($MCR1net16 $MCR1net17 $MCR2net17 $MCR1net18 $MCR1net19)

# sender network definition
MCSnet16=April
MCSnet17=August
MCSnet18=Winter
MCSnet19=Year
send_servers=($MCSnet16 $MCSnet17 $MCSnet18 $MCSnet19)

# multicast group definition
MIP=225.128.127.4
MPORT=3748

# start capturing packets
echo "Start capturing..."
for server in ${capture_servers[@]}; do
  ssh -Y $username@$server "tshark -w ~/$server-eth1.pcap -i eth1>/dev/null 2>&1 &"
done

sleep 10

# join multicast groups
echo "Joining multicast address: $MIP..."
for server in ${receive_servers[@]}; do
  ssh -Y $username@$server << EOF
echo "JOIN $MIP PORT $MPORT
listen UDP $MPORT" > receiver.mgn
mgen input receiver.mgn>/dev/null 2>&1 &
EOF
done

sleep 60

# start sending packets
echo "Start sending UDP packets to $MIP:$MPORT..."
for server in ${send_servers[@]}; do
  ssh -Y $username@$server "mgen event \"0.0 on 1 UDP DST $MIP/$MPORT periodic [0.5 500] \">/dev/null 2>&1 &"
done

sleep 60

#  stop sending packets
echo "Stop sending packets..."
for server in ${send_servers[@]}; do
  ssh -Y $username@$server "killall mgen"
done

sleep 60

# exit multicast groups
echo "Exiting multicast address: $MIP..."
for server in ${receive_servers[@]}; do
  ssh -Y $username@$server << EOF
killall mgen
EOF
done

sleep 60

# stop capturing packets and collect results
echo "Stop capturing..."
for server in ${capture_servers[@]}; do
  ssh -Y $username@$server << EOF
killall tshark
echo "Collecting results from $server..."
scp ~/*.pcap $HOST_DIR
EOF
done

echo "Finished."