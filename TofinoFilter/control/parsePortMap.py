import json
def main():
    lines = open("rawportdump.txt", "r").readlines()
    portMap = {}
    for l in lines:
        fields = l.split("|")
        if len(fields)>1:
            portName = fields[0]
            portNum = fields[2]
            if ("PORT" not in portName):
                portMap[portName.strip()] = int(portNum.strip())
    json.dump(portMap, open("portMap.json", "w"))



if __name__ == '__main__':
	main()