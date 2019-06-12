#!/bin/bash

python run_all_rates.py no_pre_95_00_booster cfgs/mcd_moongen.yml \
    --args "get_pct:.95;p_collision:.00;mcd_ip:10.0.0.10" --out '../output_2/no_pre_95_00/booster'

python run_all_rates.py no_pre_95_00_nobooster cfgs/mcd_moongen.yml \
    --args "get_pct:.95;p_collision:.00;mcd_ip:10.0.0.20" --out '../output_2/no_pre_95_00/nobooster'

python run_all_rates.py pre_95_00_booster cfgs/mcd_preset_moongen.yml \
    --args "get_pct:.95;p_collision:.00;mcd_ip:10.0.0.10" --out '../output_2/pre_95_00/booster'

python run_all_rates.py pre_95_00_nobooster cfgs/mcd_preset_moongen.yml \
    --args "get_pct:.95;p_collision:.00;mcd_ip:10.0.0.20" --out '../output_2/pre_95_00/nobooster'

python run_all_rates.py no_pre_95_05_booster cfgs/mcd_moongen.yml \
    --args "get_pct:.95;p_collision:.05;mcd_ip:10.0.0.10" --out '../output_2/no_pre_95_05/booster'

python run_all_rates.py no_pre_95_05_nobooster cfgs/mcd_moongen.yml \
    --args "get_pct:.95;p_collision:.05;mcd_ip:10.0.0.20" --out '../output_2/no_pre_95_05/nobooster'

python run_all_rates.py pre_95_05_booster cfgs/mcd_preset_moongen.yml \
    --args "get_pct:.95;p_collision:.05;mcd_ip:10.0.0.10" --out '../output_2/pre_95_05/booster'

python run_all_rates.py pre_95_05_nobooster cfgs/mcd_preset_moongen.yml \
    --args "get_pct:.95;p_collision:.05;mcd_ip:10.0.0.20" --out '../output_2/pre_95_05/nobooster'

python run_all_rates.py no_pre_95_10_booster cfgs/mcd_moongen.yml \
    --args "get_pct:.95;p_collision:.10;mcd_ip:10.0.0.10" --out '../output_2/no_pre_95_10/booster'

python run_all_rates.py no_pre_95_10_nobooster cfgs/mcd_moongen.yml \
    --args "get_pct:.95;p_collision:.10;mcd_ip:10.0.0.20" --out '../output_2/no_pre_95_10/nobooster'

python run_all_rates.py pre_95_10_booster cfgs/mcd_preset_moongen.yml \
    --args "get_pct:.95;p_collision:.10;mcd_ip:10.0.0.10" --out '../output_2/pre_95_10/booster'

python run_all_rates.py pre_95_10_nobooster cfgs/mcd_preset_moongen.yml \
    --args "get_pct:.95;p_collision:.10;mcd_ip:10.0.0.20" --out '../output_2/pre_95_10/nobooster'

python run_all_rates.py no_pre_95_20_booster cfgs/mcd_moongen.yml \
    --args "get_pct:.95;p_collision:.20;mcd_ip:10.0.0.10" --out '../output_2/no_pre_95_20/booster'

python run_all_rates.py no_pre_95_20_nobooster cfgs/mcd_moongen.yml \
    --args "get_pct:.95;p_collision:.20;mcd_ip:10.0.0.20" --out '../output_2/no_pre_95_20/nobooster'

python run_all_rates.py pre_95_20_booster cfgs/mcd_preset_moongen.yml \
    --args "get_pct:.95;p_collision:.20;mcd_ip:10.0.0.10" --out '../output_2/pre_95_20/booster'

python run_all_rates.py pre_95_20_nobooster cfgs/mcd_preset_moongen.yml \
    --args "get_pct:.95;p_collision:.20;mcd_ip:10.0.0.20" --out '../output_2/pre_95_20/nobooster'

