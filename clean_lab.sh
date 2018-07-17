# capturer network definition
PCnet16=Summer
PCnet17=Autumn
PCnet18=May
PCnet19=October
capture_servers=($Summer $Autumn $May $October)

# receiver network definition
MCR1net16=Fall
MCR1net17=November
MCR2net17=Spring
MCR1net18=July
MCR1net19=Solstice
receive_servers=($Fall $November $Spring $July $Solstice)

# sender network definition
MCSnet16=April
MCSnet17=August
MCSnet18=Winter
MCSnet19=Year
send_servers=($April $August $Winter $Year)

for server in $send_servers; do
  ssh -Y $username@$server "killall mgen"
done

for server in $receive_servers; do
  ssh -Y $username@$server "killall mgen"
done

for server in $capture_servers; do
  ssh -Y $username@$server "killall tshark"
done

echo "Finished."