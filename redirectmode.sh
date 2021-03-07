#!/bin/sh

function start() {
    if [ ! -f "/etc/iptables.txt" ]; then
        iptables-save >/etc/iptables.txt
        echo "iptables save in /etc/iptables.txt"
    fi
    load_firewall
    echo "firewall start"
}

function stop() {
    ip rule del fwmark 1 lookup 100
    if [ -f "/etc/iptables.txt" ]; then
        iptables-restore </etc/iptables.txt
        rm /etc/iptables.txt
        echo "restore iptables from /etc/iptables.txt"
    fi
    echo "firewall reset"
}

function load_firewall() {
    #only nat can use REDIRECT
    iptables -t nat -N V2RAY_NAT
    #pass lan
    iptables -t nat -A V2RAY_NAT -d 0.0.0.0/8 -j RETURN
    iptables -t nat -A V2RAY_NAT -d 10.0.0.0/8 -j RETURN
    iptables -t nat -A V2RAY_NAT -d 127.0.0.0/8 -j RETURN
    iptables -t nat -A V2RAY_NAT -d 169.254.0.0/16 -j RETURN
    iptables -t nat -A V2RAY_NAT -d 172.16.0.0/12 -j RETURN
    iptables -t nat -A V2RAY_NAT -d 192.168.0.0/16 -j RETURN
    iptables -t nat -A V2RAY_NAT -d 224.0.0.0/4 -j RETURN
    iptables -t nat -A V2RAY_NAT -d 240.0.0.0/4 -j RETURN
    iptables -t nat -A V2RAY_NAT -d 34.92.112.228 -j RETURN
    #pass china ip
    iptables -t nat -A V2RAY_NAT -m set --match-set china dst -j RETURN
    #pass mark 0x22(34)
    iptables -t nat -A V2RAY_NAT -p tcp -j RETURN -m mark --mark 0x22
    #REDIRECT tcp to port 1080
    iptables -t nat -A V2RAY_NAT -p tcp -j REDIRECT --to-ports 1080
    #add rule to PREROUTING and OUTPUT
    iptables -t nat -A PREROUTING -p tcp -j V2RAY_NAT #lan
    iptables -t nat -A OUTPUT -p tcp -j V2RAY_NAT     #self

    #use TPROXY to redirect udp
    iptables -t mangle -N V2RAY_MAN
    #pass lan
    iptables -t mangle -A V2RAY_MAN -d 0.0.0.0/8 -j RETURN
    iptables -t mangle -A V2RAY_MAN -d 10.0.0.0/8 -j RETURN
    iptables -t mangle -A V2RAY_MAN -d 127.0.0.0/8 -j RETURN
    iptables -t mangle -A V2RAY_MAN -d 169.254.0.0/16 -j RETURN
    iptables -t mangle -A V2RAY_MAN -d 172.16.0.0/12 -j RETURN
    iptables -t mangle -A V2RAY_MAN -d 192.168.0.0/16 -j RETURN
    iptables -t mangle -A V2RAY_MAN -d 224.0.0.0/4 -j RETURN
    iptables -t mangle -A V2RAY_MAN -d 240.0.0.0/4 -j RETURN
    #pass mark 0x22(34)
    iptables -t mangle -A V2RAY_MAN -p udp -j RETURN -m mark --mark 0x22
    #pass dns
    iptables -t mangle -A V2RAY_MAN -p udp --dport 53 -j RETURN
    #TPROXY udp to port 1080
    iptables -t mangle -A V2RAY_MAN -p udp -j TPROXY --on-port 1080 --tproxy-mark 0x01/0x01
    #add route
    ip route add local default dev lo table 100
    ip rule add fwmark 1 lookup 100
    #make route work right now
    ip route flush cache
    #add rule to PREROUTING

    iptables -t mangle -A PREROUTING -p udp -j V2RAY_MAN

    iptables -t mangle -N V2RAY_MARK
    iptables -t mangle -A V2RAY_MARK -d 0.0.0.0/8 -j RETURN
    iptables -t mangle -A V2RAY_MARK -d 10.0.0.0/8 -j RETURN
    iptables -t mangle -A V2RAY_MARK -d 127.0.0.0/8 -j RETURN
    iptables -t mangle -A V2RAY_MARK -d 169.254.0.0/16 -j RETURN
    iptables -t mangle -A V2RAY_MARK -d 172.16.0.0/12 -j RETURN
    iptables -t mangle -A V2RAY_MARK -d 192.168.0.0/16 -j RETURN
    iptables -t mangle -A V2RAY_MARK -d 224.0.0.0/4 -j RETURN
    iptables -t mangle -A V2RAY_MARK -d 240.0.0.0/4 -j RETURN
    iptables -t mangle -A V2RAY_MARK -m set --match-set china dst -j RETURN
    iptables -t mangle -A V2RAY_MARK -p udp -j RETURN -m mark --mark 0x22
    iptables -t mangle -A V2RAY_MARK -p udp --dport 53 -j RETURN
    iptables -t mangle -A V2RAY_MARK -p udp -j MARK --set-mark 1
    iptables -t mangle -A OUTPUT -p udp -j V2RAY_MARK
}

case $1 in
stop)
    stop
    ;;
start)
    start
    ;;
esac
