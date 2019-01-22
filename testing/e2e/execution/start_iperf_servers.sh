NUM=$1
LOGBASE=$2
BASE_PORT=4240

for i in `seq 0 $NUM`; do
    iperf3 -s -B 10.0.0.2 -J -p $(( $BASE_PORT + $i )) > ${LOGBASE}_$i.json &
done

wait
