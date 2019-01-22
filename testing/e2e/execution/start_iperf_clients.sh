NUM=$1
TIME=$2
LOGBASE=$3
BASE_PORT=4240

for i in `seq 0 $NUM`; do
    iperf3 -c 10.0.0.2 -J -B 10.0.0.1 -p $(( $BASE_PORT + $i )) -t $TIME > ${LOGBASE}_$i.json 2> ${LOGBASE}_$i.err &
done

wait
