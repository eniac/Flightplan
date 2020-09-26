# Nik Sultana, UPenn, January 2019
# R < fig7output.R --no-save

library(fmsb)
range <- data.frame(
  RRate=c(0.00000005000000000000,0), # This is 1/x where x is the Rate value from the smallest Rate in an output.csv
  Power=c(860.0,0),
  Latency=c(0.014690,0),
  Cost=c(27.0,0),
  Area=c(418.3,0))

data <- read.csv(file="fig7output.csv", header=TRUE, sep=",")
data <- rbind(range, data)
pdf("fig7output.pdf")

cols<-colorRampPalette(c("red", "black", "green", "black"))(nrow(data))
radarchart(data, cglcol = "grey60", pch=19,pty=16, plwd=3, pcol=cols, lty = c(1, 2, 3, 4), cglwd=3)
dataName <- c("Max. Performance","Legacy Extender","Server Offload (Tofino)","Server Offload (Arista)")
legend(.282,1.35, legend=dataName, seg.len=3, pch=19, bty="n", lwd=2, y.intersp=1, horiz=FALSE, col = cols, lty = c(1, 2, 3, 4))

dev.off()
