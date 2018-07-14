import re
import numpy as np
from matplotlib import pyplot as plt


def getCounterValues(fileIn):
  data = open(fileIn, "r").read()
  multTimes = [int(v) for v in re.findall("mult: (\d*)", data) if v != ""]
  solveTimes = [int(v) for v in re.findall("solve: (\d*)", data) if v != ""]
  return multTimes, solveTimes


# def plot
#   # plt.hist(encoderRseTimes, bins = 'auto', color = "blue", label = "encoder", alpha = .5)
#   plt.hist(decoderRseTimes, bins = 'auto', color = "red", label = "decoder", alpha = .5)
#   plt.legend(loc = "upper left")
#   plt.show()



if __name__ == '__main__':

  # i = number of dropped packets per block.
  encoderSamples = []
  decoderSamples = []

  print ("number of packets wanted, encoder total, decoder total, decoder mult, decoder solve")
  for pktCt in range(1, 5):
    baseDir = "../fecBoosters/profile_output/iperfClient2Server_10_4_%s"%pktCt
    encoderFile ="%s/encoder_profile.txt"%baseDir
    decoderFile = "%s/decoder_profile.txt"%baseDir

    mult, solve = getCounterValues(decoderFile)
    decoderMult = np.average(mult)
    decoderSolve = np.average(solve)

    decoderTotal = np.average([mult[i] + solve[i] for i in range(len(solve))])

    mult, solve = getCounterValues(encoderFile) 
    encoderTotal = np.average([mult[i] + solve[i] for i in range(len(solve))])

    print "%s, %s, %s, %s, %s"%(pktCt, encoderTotal, decoderTotal, decoderMult, decoderSolve)

    # plt.hist(decoder, bins = 'auto', label = "decode (%s packets)"%i, alpha = .5)
  quit()
  # plt.hist(encoderSamples[0], bins = 'auto', label = "encode", alpha = .5)
  # plt.legend(loc="upper left")
  # plt.tight_layout()
  # plt.show()
  # quit()