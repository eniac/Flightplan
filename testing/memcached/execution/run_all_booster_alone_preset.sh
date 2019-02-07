if [[ $# < 1 ]]; then
    echo "Usage $0 <label>"
    exit 0
fi

GETPCT="get_pct:.95"
BOOST="mcd_ip:10.0.0.10"
MCDT="mcd_threads:8"
MCDM="mcd_memory:4096"
RATES="0.25,0.50,0.75,1.00,1.25,1.50,1.75,2.00,2.25,2.50,2.75,3.00"

python run_rates.py $1 cfgs/booster_alone_preset.yml \
    --args "${GETPCT};${BOOST};${MCDT};${MCDM};p_collision:0" \
    --out "../new_output/upset_booster_alone/" \
    --rates "$RATES"
