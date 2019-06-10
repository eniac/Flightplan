import argparse

parser = argparse.ArgumentParser()
parser.add_argument("moongen_log")
parser.add_argument("counter_1")
parser.add_argument("counter_2")

args = parser.parse_args()


count_file = args.counter_1
for line in open(count_file):
    if line.startswith('5/0'):
        n_pkts_str = line.split()[-1]
        n_start_pkts = int(n_pkts_str[:-1])
count_file = args.counter_2
for line in open(count_file):
    if line.startswith('5/0'):
        n_pkts_str = line.split()[-1]
        n_end_pkts = int(n_pkts_str[:-1])
n_expected_pkts = (n_end_pkts - n_start_pkts)

last_line = open(args.moongen_log).readlines()[-1]
split_line = last_line.split()

for word, next_word in zip(split_line, split_line[1:]):
    if word == 'total':
        n_got = int(next_word)

print("Expected: {}\nGot: {}".format(n_expected_pkts, n_got))
print("Difference: {}".format(n_expected_pkts - n_got))

if n_expected_pkts != n_got and n_expected_pkts != n_got - 2 and n_expected_pkts != n_got - 1:
    exit(n_expected_pkts - n_got)
if n_got == 0:
    exit(-1)
exit(0)
