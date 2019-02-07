if [[ $# < 1 ]]; then
    echo "Usage $0 <label>"
    exit 0
fi

BOOST="mcd_ip:10.0.0.20"
RATES="0.01,0.02,0.05,0.10,0.15,0.20,0.25,0.30,0.35,0.40,0.45,0.50"
#RATES="0.30,0.35"
#RATES="0.25,0.50,0.75,1.00,1.25,1.50,1.75,2.00,2.25,2.50,2.75,3.00"

python run_rates.py $1 cfgs/mcd_alone_preset.yml \
    --args "${BOOST};p_collision:0" \
    --out "../new_output/upset_mcd_alone/" \
    --rates "$RATES"
