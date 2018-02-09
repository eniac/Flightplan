# get statistics

from matplotlib import pyplot as plt
import numpy as np

def main():

	Y_avg = []
	Y_std = []

	X = [3] + range(10, 141, 10)
	expNames = ["fecK.%s"%x for x in X]
	plt.figure(figsize=(4, 3))
	for i, expName in enumerate(expNames):
		fn = "../benchmarkData/pcapThroughput.%s.txt"%expName
		lines = open(fn, "r").readlines()
		lines = [l.split(",") for l in lines[1::]]
		XY = [(int(l[0]), int(l[1])) for l in lines]
		X_tmp, Y = zip(*XY)
		Y = [y/1000.0 for y in Y]
		Y = Y[3:11]

		avg = np.average(Y)
		Y_avg.append(avg)
		Y_std = np.std(Y)
		print X
		print Y_avg


	plt.plot(X, Y_avg, marker = "x")
	# leg = plt.legend(loc = "center")
	plt.xlabel("K")
	plt.ylabel("Throughput (Gb/s)")
	plt.tight_layout()
	# plt.subplots_adjust(top=0.8)
	plt.savefig("2-8-18-K.pdf")
	plt.show()

	quit()


if __name__ == '__main__':
	main()