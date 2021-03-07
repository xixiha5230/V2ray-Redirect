#!/bin/sh

FilePath=$(
    cd "$(dirname "$0")"
    pwd
)
geoipurl="https://github.com/Loyalsoldier/v2ray-rules-dat/releases/latest/download/geoip.dat"
geositeurl="https://github.com/Loyalsoldier/v2ray-rules-dat/releases/latest/download/geosite.dat"

cd $FilePath
echolog() {
    logger snodeLog "$*"
}

newrule() {
    cd $FilePath/xray
    mv geoip.dat geoip.old
    mv geosite.dat geosite.old
    wget $geoipurl -O geoip.dat
    wget $geositeurl -O geosite.dat
    if [ ! -f "./geoip.dat" ]; then
        mv geoip.old geoip.dat
    fi
    if [ ! -f "./geosite.dat" ]; then
        mv geosite.old geosite.dat
    fi
    chmod +x *
    #update ipset
    cd ..
    #remove anti AD dns,dont work find
    #    ./antiad.sh update
    #    ./antiad.sh start
    ./custipset.sh update
    stop
    sleep 1
    ./custipset.sh restart
    start
    echolog "download geoip geosite done!"
}

switch() {
    while read line; do
        eval "$line"
    done <snode.config
    echolog "node "$num""
    echo "node "$num""
    echo "total "$total""

    killall -9 xray

    cd xray
    head=$(cat head.json)
    node=$(cat $num.json)
    rule=$(cat rule.json)
    echo "$head$node$rule" >node.json
    ####
    #solve too many file open !!! usefull !!!!
    # etc/sysctl.conf add fs.file-max=65536
    LimitNOFILE=1048576
    LimitNPROC=1048576
    ulimit -S -n 4096
    ####
    ./xray -config node.json 2>&1 &
    sleep 1

    cd ..
    num=$(($num + 1))
    num=$(($num % $total))
    sed -i "s/num=[0-9]*/num="$num"/g" snode.config
}

start() {
    ./custipset.sh start
    ./redirectmode.sh start
    switch
}

stop() {
    ./redirectmode.sh stop
    killall -9 xray
}

case $1 in
newrule)
    newrule
    ;;
stop)
    stop
    ;;
start)
    start
    # need restart
    service https-dns-proxy restart
    ;;
restart)
    stop
    sleep 1
    start
    ;;
changeNode)
    switch
    ;;
test) ;;

esac
