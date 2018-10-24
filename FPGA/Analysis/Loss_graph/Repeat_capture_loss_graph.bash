#!/bin/bash -e
for NR in $(seq 9 20)
do
  ./Capture_loss_graph.bash
  mv Loss.csv Loss_${NR}.csv
done

