# get statistics

from matplotlib import pyplot as plt
import numpy as np

def main():
	expNames = ["lineRate", "noFec", "fec8", "fec1"]
	names = ["Tofino", "Tofino + x86 Fwd", "Tofino + x86 FEC (8 cores)", "Tofino + x86 FEC (1 core)"]
	# allNames = ["Tofino", "Tofino + x86 Fwd", "Tofino + x86 FEC (8)", "Tofino + x86 FEC (4)", "Tofino + x86 FEC (2)", "Tofino + x86 FEC (1)"]
	f = plt.figure(figsize=(4, 3))
	ax = f.add_subplot(111)
	print("Experiment, Avg Throughput (Gb/s), Std. Dev.")
	for i, expName in enumerate(expNames):
		fn = "../benchmarkData/pcapThroughput.%s.txt"%expName
		lines = open(fn, "r").readlines()
		lines = [l.split(",") for l in lines[1::]]
		XY = [(int(l[0]), int(l[1])) for l in lines]#[5:60]
		X, Y = zip(*XY)
		# Y = [y*1000.0*1000.0 for y in Y]
		Y = [y/1000.0 for y in Y]
		plt.plot(X, Y, label=names[i], marker = "x")
		Y = Y[5:60]
		avg = np.average(Y)
		dev = np.std(Y)
		print ("%s, %s, %s"%(names[i], avg, dev))

	# leg = plt.legend(loc = "center")
	plt.legend(bbox_to_anchor=(-0.15, 1.05, 1.20, .102), loc=3,
           ncol=2, mode="expand", borderaxespad=0., handletextpad=0.1)
	# plt.ylim((100*1000*1000, 11000*1000*1000))
	plt.xlabel("Time (seconds)")
	plt.ylabel("Throughput (Gb/s)")
	# plt.yscale("log")
	# plt.yticks([100*1000*1000, 1000*1000*1000, 10000*1000*1000], ['100 Mb/s', '1 Gb/s', '10 Gb/s'])
	plt.tight_layout()
	plt.text(-.15, -.15,'CPU: Xeon E5 2650\n(8 cores @ 2.0 Ghz)',
     horizontalalignment='left',
     verticalalignment='top',
     transform = ax.transAxes, fontsize = 8)

	plt.subplots_adjust(top=0.8)
	plt.savefig("2-8-18-cpu.pdf")
	plt.show()

	quit()


if __name__ == '__main__':
	main()