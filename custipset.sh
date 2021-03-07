#!/bin/sh

chinaipurl="https://ftp.apnic.net/stats/apnic/delegated-apnic-latest"
cnzoneurl="http://www.ipdeny.com/ipblocks/data/countries/cn.zone"

ChinaListMode=0

function updateChinaList1() {
    wget --no-check-certificate $chinaipurl
    cat delegated-apnic-latest | awk -F '|' '/CN/&&/ipv4/ {print $4 "/" 32-log($5)/log(2)}' | cat >cn.zone1
    rm delegated-apnic-latest
}

function updateChinaList2() {
    wget --no-check-certificate $cnzoneurl -O cn.zone2
}

function updateALL() {
    case $ChinaListMode in
    0)
        updateChinaList1
        updateChinaList2
        cat cn.zone1 >cn.zone
        cat cn.zone2 >>cn.zone
        rm cn.zone1 cn.zone2
        sort -u cn.zone >tmp
        mv tmp cn.zone
        ;;
    1)
        updateChinaList1
        mv cn.zone1 cn.zone
        ;;
    2)
        updateChinaList2
        mv cn.zone2 cn.zone
        ;;
    -1) ;;

    esac
}

function startIpset() {
    if ($(ipset -N china hash:net)); then
        for i in $(cat ./cn.zone); do
            ipset -A china $i
        done
        echo "ipset loaded China list"
    fi
}

function stopIpset() {
    ipset destroy china
    echo "ipset destroy china"
}

case $1 in
start)
    startIpset
    ;;
stop)
    stopIpset
    ;;
restart)
    stopIpset
    startIpset
    ;;
update)
    updateALL
    ;;
test) ;;

esac
