#!/usr/bin/bash
#variables
source /root/haqqwatcher/.env
freeMem=$(free -g |tail -n2|awk '{print $6}')
let "freeDisk = $(df /|tail -n1|awk '{print $4}')/1048576"
missedBlocks=$(haqqd q slashing signing-info $(haqqd tendermint show-validator) -o json |jq .missed_block_counter)

#some message templates
msgJailed="⚡HAQQ WATCHER alert ⚡ [$MONIKER] in JAIL! %0A [$IP] %0A $VALOPER%0A Command to unjail: %0A haqqd tx slashing unjail --from wallet --chain-id haqq_54211-2"
msgUnjailed="✅ HAQQ WATCHER info ✅ [$MONIKER] unjailed! %0A [$IP] %0A $VALOPER%0A"
msgDiskInfo="⚠️ HAQQ WATCHER info ⚠️ [$MONIKER] Low disk space! %0A Only $freeDisk[G] free. %0A [$IP]"
msgDiskCritical="⚡ HAQQ WATCHER alert ⚡️ [$MONIKER] The disk is almost full! ! %0A Only $freeDisk[G] free. %0A [$IP]"
msgMem="⚠️ HAQQ WATCHER info ⚠️ [$MONIKER] Low free RAM! %0A Only $freeMem[G] free. %0A [$IP]"

#Jail check
jail=$(haqqd query staking validator $VALOPER -o json | jq .jailed)
if $jail; then
 if ! $(test -f /root/haqqwatcher/.jail); then
      curl -s -X POST $TG_URL -d chat_id=$TG_CHAT_ID -d text="$msgJailed"
      touch /root/haqqwatcher/.jail
 fi
else
if $(test -f /root/haqqwatcher/.jail); then
     curl -s -X POST $TG_URL -d chat_id=$TG_CHAT_ID -d text="$msgUnjailed"
     rm /root/haqqwatcher/.jail
  fi
fi

#Proposal check
voteChecked=$(cat $HOME/haqqwatcher/.proposal)
voteLastNumber=$(haqqd q gov proposals|grep proposal_id|tail  -n 1| awk '{print $2}' | tr -d \")
voteLastDescription=$(haqqd q gov proposals|grep description|tail -n 1)
votelastTitle=$(haqqd q gov proposals|grep title|tail -n 1)
if test -f $HOME/haqqwatcher/.proposal; then
if [ "$voteLastNumber" -gt "$voteChecked" ]; then
msgProposal="✅ HAQQ WATCHER info ✅ %0A New proposal $voteLastNumber  %0A$votelastTitle  %0A$voteLastDescription %0A Example command to vote: haqqd tx gov vote $voteLastNumber yes --from wallet --fees 500aISLM"
curl -s -X POST $TG_URL -d chat_id=$TG_CHAT_ID -d text="$msgProposal" #-d parse_mode='Markdown'
echo $voteLastNumber > $HOME/haqqwatcher/.proposal
fi
fi

#Missed block check
missedBlocks=$(haqqd q slashing signing-info $(haqqd tendermint show-validator) -o json |jq .missed_block_counter)
if  [ "$missedBlocks" != "null" ] ; then
    if [ "$missedBlocks" -ge "MISSED_ALERT" ]; then
       if ! $(test -f /root/haqqwatcher/.miss); then
             curl -s -X POST $TG_URL -d chat_id=$TG_CHAT_ID -d text="$msgMissed"
             touch $HOME/haqqwatcher/.mem
       fi
    else
      if test -f $HOME/haqqwatcher/.mem; then rm $HOME/haqqwatcher/.mem; fi
   fi
fi

#Disk check
if [ "$freeDisk" -le "$FS_ALERT_INFO" ]; then
     if [ "$freeDisk" -le "$FS_ALERT_CRITICAL" ]; then
        if ! $(test -f $HOME/haqqwatcher/.disk_crit); then
          curl -s -X POST $TG_URL -d chat_id=$TG_CHAT_ID -d text="$msgDiskCritical"
          touch $HOME/haqqwatcher/.disk_crit
        fi
      else if ! $(test -f $HOME/haqqwatcher/.disk_info); then
           curl -s -X POST $TG_URL -d chat_id=$TG_CHAT_ID -d text="$msgDiskInfo"
           touch $HOME/haqqwatcher/.disk_info
      fi
    fi
else
   if test -f $HOME/haqqwatcher/.disk_crit; then rm $HOME/haqqwatcher/.disk_crit; fi
   if test -f $HOME/haqqwatcher/.disk_info; then rm $HOME/haqqwatcher/.disk_info; fi
fi

#Memory check

if [ "$freeMem" -le "$MEM_ALERT" ]; then
        if ! $(test -f $HOME/haqqwatcher/.mem); then
          curl -s -X POST $TG_URL -d chat_id=$TG_CHAT_ID -d text="$msgMem"
          touch $HOME/haqqwatcher/.mem
        fi
else
if test -f $HOME/haqqwatcher/.mem; then rm $HOME/haqqwatcher/.mem; fi
fi
