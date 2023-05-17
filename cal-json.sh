#!/bin/sh
LOG=$1
if [ -z $LOG ];then
  LOG=`date +%Y%m%d`
fi
WORK=/tmp/work.$$
COUNT=`cat $LOG | jq '.jobs' | grep jobname| wc -l`

for (( i=0 ; i<${COUNT} ; i++ ))
do
#  T=""
  NAME=`cat $LOG | jq ".jobs[$i].jobname"`
  BW1=`cat $LOG | jq ".jobs[$i].read.bw"`
  BW2=`cat $LOG | jq ".jobs[$i].write.bw"`
  BW=`echo "scale=0; ($BW1 + $BW2) /1000" | bc`"MB"
  IOPS1=`cat $LOG | jq ".jobs[$i].read.iops"`
  IOPS2=`cat $LOG | jq ".jobs[$i].write.iops"`
  IOPS=`echo "scale=0; $IOPS1 + $IOPS2"| bc | sed 's/\..*//g'`

  NS=`cat $LOG | jq ".jobs[$i].latency_ns" | sed 's/,$//g' | awk 'BEGIN{n=0;m=0} /^ / {if(m<$2){ m=$2 ;n=$1 }} END{print "ns "n" "m}'`
  US=`cat $LOG | jq ".jobs[$i].latency_us" | sed 's/,$//g' | awk 'BEGIN{n=0;m=0} /^ / {if(m<$2){ m=$2 ;n=$1 }} END{print "us "n" "m}'`
  MS=`cat $LOG| jq ".jobs[$i].latency_ms" | sed 's/,$//g' | awk 'BEGIN{n=0;m=0} /^ / {if(m<$2){ m=$2 ;n=$1 }} END{print "ms "n" "m}'`
  echo $NS > $WORK
  echo $US >> $WORK
  echo $MS >> $WORK
  LATENCY=`cat $WORK | awk 'BEGIN{n=0;m=0;name} {if(m<$3){ m=$3 ;n=$2; name=$1 }} END{print name n m}'`

  printf " %20s bw:%5s iops:%5s latency:%5s\n" $NAME $BW $IOPS $LATENCY
done

rm -rf $WORK
exit;
