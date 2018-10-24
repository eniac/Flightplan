#!/usr/bin/Rscript
Throughputs = c()
X = c()
Y = c()
for (i in 1:16)
{
  Data = read.csv(paste0('Loss_', i, '.csv'), header = FALSE)
  Throughputs = c(Throughputs, Data[1, 1])
  Data = Data[-1, ]
  X = c(X, Data[, 1])
  Y = c(Y, Data[, 2])
}

Predictions = c()
for (p in unique(X))
{
  # 0 or 1 packets are lost: Full recovery
  Recovery = pbinom(1, 6, p)

  # More than 1 packet is lost, none of them is a parity packet
  for (i in 2:5)
  {
    Recovery = Recovery + p^i * (1 - p)^(6 - i) * choose(5, i) * (1 - i / 5)
  }

  # More than 1 packet is lost, one of them is a parity packet
  for (i in 2:6)
  {
    Recovery = Recovery + p^i * (1 - p)^(6 - i) * choose(5, i - 1) * (1 - (i - 1) / 5)
  }

  Predictions = c(Predictions, 1 - Recovery)
}

pdf(file = "Loss_graph.pdf", width = 6 + 2 / 3, height = 4.2)
boxplot(Y ~ X, at = unique(X), log = "xy", xlim = range(X), ylim = range(Y))
par(new = TRUE)
plot(unique(X), Predictions, log = "xy", type = "o", xlim = range(X), ylim = range(Y),
     axes = FALSE, xlab = "Link loss rate (packet/s)", ylab = "Observed loss rate (packet/s)",
     col = "red")

