#!/bin/sh
#Identify Tethering interface
if [[ `ip link show usb0 2>/dev/null` ]]; then
        TetherIface="usb0"
elif [[ `ip link show rndis0 2>/dev/null` ]]; then
        TetherIface="rndis0"
else
        echo "Please enter Tetehring interface:"
        read TetherIface
fi

# Identify temp directory
if [ -d "/tmp" ]; then
  TEMP="/tmp"
elif [ -d "/data/local/tmp" ]; then #android env
  TEMP="/data/local/tmp"
elif [ -d "/cache" ]; then 
  TEMP="/cache"
else 
	echo "TEMP folder cannot be found, setting it to pwd"
	TEMP=`pwd`
fi

# Kill responder if still running
echo "Stopping Responder"
if [ -f $TEMP/responder.pid ] ; then
        kill "`cat $TEMP/responder.pid`" 2>/dev/null
        rm $TEMP/responder.pid
else
	echo "Responder not found running"
fi

# Check if previous usb setup exists
if [ ! -f $TEMP/usb_tether_prevconfig ] ; then
	echo '$TEMP/usb_tether_prevconfig not found. Is tethering really active?' >&2
fi

# Stop dnsmasq. If pid file does not exist, kill it 
echo "Stopping DHCP"
if [ -f $TEMP/usb_tether_dnsmasq.pid ] ; then
	kill "`cat $TEMP/usb_tether_dnsmasq.pid`"
	rm $TEMP/usb_tether_dnsmasq.pid
else
	echo "Killing all dnsmasq instances" 
	# *Shouldn't* be other legitimate ones running and there's no other easy way to do it	
	killall dnsmasq
fi

# If forwarding was set up, remove it
if [ -f $TEMP/netiface.name ]; then
	NetIface=`cat $TEMP/netiface.name`
	# Stop forwarding
	echo "Disabling Forwarding"
	echo 0 > /proc/sys/net/ipv4/ip_forward

	# Stop NATting
	echo "Removing NATing: $TetherIface -> $NetIface"
	/system/bin/iptables -w -D natctrl_FORWARD -i $NetIface -o $TetherIface -m state --state ESTABLISHED,RELATED -g natctrl_tether_counters
	/system/bin/iptables -w -D natctrl_FORWARD -i $TetherIface -o $NetIface -m state --state INVALID -j DROP
	/system/bin/iptables -w -D natctrl_FORWARD -i $TetherIface -o $NetIface -g natctrl_tether_counters
	/system/bin/iptables -w -F natctrl_FORWARD
	/system/bin/iptables -w -A natctrl_FORWARD -j DROP
	/system/bin/iptables -w -t nat -F natctrl_nat_POSTROUTING

	rm $TEMP/netiface.name
fi

sleep 1

# Bring down Tethering interface
echo "Bringing $TetherIface interface down"
ip link set $TetherIface down
ip addr flush dev $TetherIface
ip rule del from all lookup main

sleep 1

# Revert to previous usb setup, if does not exist set to mtp & adb (most common setup)
if [ -f $TEMP/usb_tether_prevconfig ] ; then
	echo "Setting USB interface to the old config:" `cat $TEMP/usb_tether_prevconfig`
	setprop sys.usb.config `cat $TEMP/usb_tether_prevconfig`
	rm $TEMP/usb_tether_prevconfig
elif [[ `getprop sys.usb.config` == *"rndis"* ]] ; then
	echo "Old config not found, setting usb interface to: mtp,adb"
	setprop sys.usb.config 'mtp,adb'
else
	echo "USB interface not in rndis mode, Skipping ..."
fi
# Wait for usb inteface to change state
while [ "$(getprop sys.usb.state)" = 'rndis,adb' ] ; do sleep 1 ; done
# TODO: File cleanup
echo "Finished"
echo "Current Config:" `getprop sys.usb.config`
