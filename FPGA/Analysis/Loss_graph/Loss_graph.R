#!/usr/bin/Rscript
Data = read.csv('Loss.csv', header = FALSE)
Data = Data[Data[, 1] == 79, ]
Matrix = t(data.matrix(Data[, 3:ncol(Data)]))
X = unique(Data[, 2])
colnames(Matrix) = X
Range = range(Matrix)
if (min(Matrix) == 0)
{
  Range[1] = 1e-6
}

Matrix

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
boxplot(Matrix, at = X, log = "xy", xlim = range(X), ylim = Range)
par(new = TRUE)
plot(unique(X), Predictions, log = "xy", type = "o", xlim = range(X), ylim = Range,
     axes = FALSE, xlab = "Link loss rate (packet/s)", ylab = "Observed loss rate (packet/s)",
     col = "red")

