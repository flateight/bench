# bench

### Ubuntu
    sudo apt -y install dbench fio jq bc ipmitool make gcc

### CentOS
    yum -y install epel-release
    yum -y install dbench fio jq bc ipmitool
    yum -y install make gcc


### FIO
    fio -f fio_config.txt --output-format=json > `date +%Y%m%d` && bash cal-json.sh

### UnixBench
    cd byte-unixbench/UnixBench && ./Run -i 3 -c 1

### memtier_benchmark
    systemctl start redis
    memtier_benchmark --hide-histogram -t 4 -c 100 -R --ratio=1:2 -d 100000 -n 10000
