## HAQQ WATCHER

This small utility can be useful if you want to receive information about the status of the validator in Telegram without depending on third-party services.

The script is installed on the machine with the node and allows you to receive telegram notifications about the following events:

-   Validator goes to jail
-   Unjail validator
-   Missed blocks
-   New proposal 
-   Small amount of free RAM on the node
-   Running out of disk space
-   other notifications

When a notification is received, the message contains a hint for how to react to the event (for example, how to vote or a command to unjail), which can be useful if only a phone is at hand.

**Notification examples:**

> ✅ HAQQ WATCHER info ✅ New proposal 151 title: Staking Param Change
> description: Decrease Unbonding period to 8 days Command to vote:
> haqqd tx gov vote 151 yes --from wallet --fees 500aISLM


> ⚡️HAQQ WATCHER alert ⚡️ [MaxBoot] in JAIL! [195.52.40.128]
> haqqvaloper1mxjx2hslq32d5a0tzsgxc2txwpay766xbfz Command to unjail:
> haqqd tx slashing unjail --from wallet --chain-id haqq_54211-2


> ✅ HAQQ WATCHER info ✅ [MaxBoot] unjailed! [195.52.40.128]
> haqqvaloper1mxjx2hslq32d5a0tzsgxc2txwpay766xbfz


> ⚠️ HAQQ WATCHER info ⚠️ [MaxBoot] Low disk space! Only 10[G] free.
> [195.52.40.128]


**Installation requirements:**

-   Your telegram bot (namely chat id and token - if not, you need to create one)
-   Address of your validator (**haqqd keys show wallet --bech val -a** or just copy from explorer)

**Installation:**

    cd
    wget -O hw_install.sh https://github.com/maxbutenko/HaqqWatcher/raw/main/hw_install.sh && chmod +x ./hw_install.sh && ./hw_install.sh

The installer will ask for the validator address and telegram bot details. After receiving the test message, the script will run as a service, checking the parameters every 15 seconds. To view the logs, enter the command:

    journalctl -u haqqwatcher -f -o cat

**This completes the installation.**

To stop notifications, just stop the service:

    systemctl stop haqqwatcher

For complete removal:

    systemctl stop haqqwatcher
    systemctl disable haqqwatcher
    rm -rf /root/haqqwatcher
    rm /root/hw_install.sh

Thank you for your attention!
