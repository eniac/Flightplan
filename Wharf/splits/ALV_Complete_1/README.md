Compression disabled in this example because of a weird bug -- it seems that there's something stopping the FEC decoding from working properly.
`command time sudo bash -c "source /home/nsultana/envir.sh; MODE=complete_mcd_e2e splits/ALV_Complete_1/tests.sh"`
`command time sudo bash -c "source /home/nsultana/envir.sh; MODE=complete_fec_e2e splits/ALV_Complete_1/tests.sh"`
