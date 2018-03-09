#scrap

from matplotlib import pyplot as plt
import math

def main():
	plt.figure(figsize=(4,3))
	X = range(2, 10000, 100)
	Yp = [min(10, 10 * (1.0/math.log(x))) for x in X]
	Xp = [float(x)/max(X) for x in X]
	plt.plot(Xp, Yp, label="No FEC")

	X = range(4, 10000, 100)
	Yp = [min(10, 10 *(2.0/math.log(x))) for x in X]
	Xp = [float(x)/max(X) for x in X]
	plt.plot(Xp, Yp, label="H = 5 K = 5")

	X = range(4, 10000, 100)
	print X
	Yp = [min(10, 10 *(4.0/math.log(x))) for x in X]	
	Xp = [float(x)/max(X) for x in X]
	plt.plot(Xp, Yp, label="H = 10 K = 5")

	X = range(4, 10000, 100)
	Yp = [min(10, 10 *(8.0/math.log(x))) for x in X]
	Xp = [float(x)/max(X) for x in X]
	plt.plot(Xp, Yp, label="H = 20 K = 5")


	plt.xlabel("Loss Rate")
	plt.ylabel("Throughput (Gbps)")
	plt.legend(loc = "upper right", ncol=2)
	plt.tight_layout()
	plt.xlim((0, .5))
	plt.ylim((0, 14))
	plt.savefig("fake_tput.pdf")
	plt.show()

if __name__ == '__main__':
	main()