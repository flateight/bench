#!/bin/bash

BASE_DIR=$(cd $(dirname $0); pwd)
usage_exit() {
        echo "Usage: $0 [-m] " 1>&2
        exit 1
}

MEMBENCH=0
while getopts m OPT
do
    case $OPT in
        m)  MEMBENCH=1
        ;;
        \?) usage_exit
            ;;
    esac
done
shift $(($OPTIND - 1))

### Ubuntu support
if [ -n "`grep Ubuntu /etc/os-release`" ];then
    sudo apt update
    sudo apt -y install dbench fio jq bc ipmitool make gcc
    sudo apt -y install redis
else
    sudo yum -y install epel-release
    sudo yum -y install git dbench fio jq bc ipmitool make gcc
fi

### Unixbench
git clone https://github.com/kdlucas/byte-unixbench
cd byte-unixbench/UnixBench
make
cd $BASE_DIR

if [ $MEMBENCH == 1 ];then
    ### Ubuntu support
    if [ -n "`grep Ubuntu /etc/os-release`" ];then
        sudo apt -y install autoconf automake g++ pkg-config
        sudo apt -y install build-essential libpcre3-dev libevent-dev zlib1g-dev libssl-dev
    else
        sudo yum -y install autoconf automake gcc-c++ libevent-devel openssl-devel
        sudo yum -y install redis
    fi
    ### memtier_benchmark
    git clone https://github.com/RedisLabs/memtier_benchmark.git
    cd memtier_benchmark
    autoreconf -ivf
    ./configure
    make
    make install
    cd $BASE_DIR
fi

cat << __EOM__

------------------------------------------------------------------------
### FIO
fio -f fio_config.txt --output-format=json > \`date +%Y%m%d\` && bash cal-json.sh

### UnixBench
cd byte-unixbench/UnixBench && ./Run -i 3 -c 1

__EOM__

if [ $MEMBENCH == 1 ];then
cat << __EOM__
### memtier_benchmark
systemctl start redis
memtier_benchmark --hide-histogram -t 4 -c 100 -R --ratio=1:2 -d 100000 -n 10000

__EOM__
fi

exit 0;
