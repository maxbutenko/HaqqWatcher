#!/bin/bash
echo "  "
if test -d $HOME/haqqwatcher/; then echo "Reconfigurate..."; else mkdir /$HOME/haqqwatcher; fi
if test -f $HOME/haqqwatcher/haqqwatcher.sh; then wget -q -O /root/haqqwatcher/haqqwatcher.sh https://github.com/maxbutenko/HaqqWatcher/raw/main/haqqwatcher.sh && chmod +x /root/haqqwatcher/haqqwatcher.sh; fi
if test -f $HOME/haqqwatcher/.env; then rm $HOME/haqqwatcher/.env; fi
# variables
IP=$(curl ifconfig.me 2> /dev/null)
FS_ALERT_INFO=15
FS_ALERT_CRITICAL=5
MISSED_BLOCKS_ALERT=20
MEM_ALERT=2
HAQQD=$(which haqqd)
#
echo 'IP='$IP>> $HOME/haqqwatcher/.env
echo 'FS_ALERT_INFO='$FS_ALERT_INFO>> $HOME/haqqwatcher/.env
echo 'FS_ALERT_CRITICAL='$FS_ALERT_CRITICAL>> $HOME/haqqwatcher/.env
echo 'MISSED_BLOCKS_ALERT='$MISSED_BLOCKS_ALERT>> $HOME/haqqwatcher/.env
echo 'MEM_ALERT='$MEM_ALERT>> $HOME/haqqwatcher/.env
echo 'HAQQD='$HAQQD>> $HOME/haqqwatcher/.env
#
echo "  "
echo "#################################################"
echo "#          HAQQ WATCHER             by MaxBoot  #"
echo "#################################################"
echo "  "
  read -p "Enter validator address(haqqvaloper...): " VALOPER
        echo 'VALOPER='$VALOPER >> $HOME/haqqwatcher/.env
  read -p "Enter telegram token: " TG_TOKEN
        echo 'TG_TOKEN='$TG_TOKEN >> $HOME/haqqwatcher/.env
  read -p "Enter telegram chat ID: " TG_CHAT_ID
        echo 'TG_CHAT_ID='$TG_CHAT_ID>> $HOME/haqqwatcher/.env

PROPOSAL=$(haqqd q gov proposals|grep proposal_id|tail  -n 1| awk '{print $2}'|tr -d \")
echo $PROPOSAL > $HOME/haqqwatcher/.proposal
MONIKER=$(haqqd query staking validator $VALOPER -o json| jq .description.moniker)
echo 'MONIKER='$MONIKER >> $HOME/haqqwatcher/.env
echo "  "
echo "Your moniker is $MONIKER"
echo "  "
echo "Sending test message..."
echo "  "
TG_URL="https://api.telegram.org/bot$TG_TOKEN/sendMessage"
echo 'TG_URL='$TG_URL>> $HOME/haqqwatcher/.env

freeDisk=$(df -h /|tail -n1|awk '{print $4}')
MESSAGE=" ✅ HAQQ WATCHER info ✅%0A Test message %0A [$IP] | $MONIKER | Free Space: [$freeDisk] "
curl -s -X POST $TG_URL -d chat_id=$TG_CHAT_ID -d text="$MESSAGE"
echo "  "
read -p "Did you receive test message with your moniker? (y/n) " RESULT
if [ "$RESULT" = "y" ]; then echo "Great! All systems ready.";
else
echo "  "
echo "Please check telegram bot TOKEN and chat ID and run script again "
echo "  "
sleep 3
exit
fi
