# get statistics

from matplotlib import pyplot as plt
import numpy as np

def main():
	expNames = ["lineRate", "noFec", "fec"]
	names = ["No Booster", "Passthrough", "FEC"]
	plt.figure(figsize=(4, 3))
	print("Experiment, Avg Throughput (Gb/s), Std. Dev.")
	for i, expName in enumerate(expNames):
		fn = "../benchmarkData/pcapThroughput.%s.txt"%expName
		lines = open(fn, "r").readlines()
		lines = [l.split(",") for l in lines[1::]]
		XY = [(int(l[0]), int(l[1])) for l in lines]
		X, Y = zip(*XY)
		Y = [y/1000.0 for y in Y]
		plt.plot(X, Y, label=names[i], marker = "x")
		Y = Y[10:60]
		avg = np.average(Y)
		dev = np.std(Y)
		print ("%s, %s, %s"%(names[i], avg, dev))

	# leg = plt.legend(loc = "center")
	plt.legend(bbox_to_anchor=(0., 1.02, 1., .102), loc=3,
           ncol=3, mode="expand", borderaxespad=0.)
	plt.ylim((-1, 11))
	plt.xlabel("Time (s)")
	plt.ylabel("Throughput (Gb/s)")
	plt.tight_layout()
	plt.subplots_adjust(top=0.9)
	plt.savefig("2-8-18-cpu.pdf")
	plt.show()

	quit()


if __name__ == '__main__':
	main()