import yaml
import pprint
import copy
import os
import datetime
import subprocess
from datetime import datetime
from collections import defaultdict
from argparse import ArgumentParser

def update_requirements(req, all_reqs):
    if isinstance(req, dict):
        if len(req) > 1:
            raise Exception(("Requirements entries should be lists of at-most" +
                            "1-item dictionaries. {} has {} items")
                            .format(req, len(req)))
        key = req.keys()[0]
        vals = all_reqs[key]
        for val in req[key]:
            update_requirements(val, vals)
    else:
        all_reqs[req].update({})

def dictize_requirements(all_reqs):
    all_reqs = copy.deepcopy(all_reqs)
    for k in all_reqs.keys():
        if isinstance(all_reqs[k], defaultdict):
            all_reqs[k] = dictize_requirements(all_reqs[k])
    return dict(all_reqs)

def read_requirements(submission, req_file = None):
    if req_file is None:
        req_file = os.path.join(os.path.dirname(__file__), 'requirements.yml')

    if 'experiment' not in submission:
        raise Exception("'experiment' always a required field in submission")
    experiment = submission['experiment']
    try:
        with open(req_file) as f:
            reqs = yaml.load(f)
    except Exception:
        print("Error opening requirements file {}".format(req_file))
        raise

    if 'all' not in reqs:
        raise Exception('"all" is a necessary field in requirements.yml')

    reqs_all = reqs['all']
    ddict = lambda : defaultdict(ddict)

    reqs_complete = ddict()

    for req in reqs_all:
        update_requirements(req, reqs_complete)

    if experiment not in reqs:
        raise Exception(('Experiment "{0}" is not listed in requirements file. ' + \
                'If no additional requirements, add the line: ' + \
                '"{0}: []"').format(experiment))

    reqs_exp = reqs[experiment]

    for req in reqs_exp:
        update_requirements(req, reqs_complete)

    return dictize_requirements(reqs_complete)

def check_requirements(submission, reqs, prefix=''):
    for k, v in reqs.items():
        if not isinstance(submission, dict):
            raise Exception("{} should be a dict, not {}".format(prefix, type(submission)))
        if k not in submission:
            raise Exception("Submission is missing section {}{}".format(prefix, k))
        if not isinstance(submission[k], (dict, str)):
            raise Exception("Submission should contain only dicts and strings, not " + \
                    prefix + k + ": " + str(type(submission[k])))
        for k2, v2 in v.items():
            if k2 not in submission[k]:
                raise Exception("Submission is missing subsection {}{}:{}".format(prefix, k, k2))
            check_requirements(submission[k][k2], v2, prefix + k + ":" + k2 + ":")

SSH_CMD = 'ssh -i {key} {user}@{addr} "{cmd}"'
RSYNC_CMD = "rsync -av -e 'ssh -i {key}' {src} {user}@{addr}:{dst}"

def ssh_cmd(cmd, addr, key=None, user=None):
    c = 'ssh '
    if key:
        c += '-i {} '.format(key)
    if user:
        c += user + '@'
    c += addr
    c += ' "{}"'.format(cmd)
    return c

def rsync_cmd(src, dst, addr, key=None, user=None):
    c = 'rsync -av '
    if key:
        c += "'ssh -i {}' ".format(key)
    c += src + ' '

    if user:
        c += user + '@'

    c += '{}:{}'.format(addr, dst)
    return c

def check_files(submission):
    for k, v in submission['files'].items():
        if not os.path.exists(v):
            raise Exception("Required file {} ({}) DNE".format(v, k))

def rsync_all(submission, submission_file, label, key=None, user=None, addr='dcomp1.seas.upenn.edu', exp_dir='/harvest/experiments'):
    ssh = dict(key=key, user=user, addr=addr)
    this_exp_dir = os.path.join(exp_dir, submission['experiment'], os.getlogin(), label)

    print("Making directory {}".format(this_exp_dir))

    cmd = ssh_cmd('mkdir -p ' + this_exp_dir, **ssh)
    subprocess.check_call(cmd, shell=True)


    sub_dst = os.path.join(this_exp_dir, 'submission.yml')
    print("Copying submission file {} to {}".format(submission_file, sub_dst))
    cmd = rsync_cmd(submission_file, sub_dst, **ssh)
    subprocess.check_call(cmd, shell=True)

    for fname, src in submission['files'].items():
        file_dst = os.path.join(this_exp_dir, fname)
        cmd = rsync_cmd(src, file_dst, **ssh)
        print("Copying file {} to {}".format(src, file_dst))
        subprocess.check_call(cmd, shell=True)

    print("Copied files to {}".format(this_exp_dir))

def read_submission(sub_file):
    with open(sub_file) as f:
        sub = yaml.load(open(sub_file))

    for k in sub['files']:
        sub['files'][k] = os.path.join(os.path.dirname(sub_file), sub['files'][k])

    return sub

def run(sub_file, label, key, user):
    sub = read_submission(sub_file)
    reqs = read_requirements(sub)
    check_requirements(sub, reqs)
    check_files(sub)
    rsync_all(sub, sub_file, label, key, user)

if __name__ == '__main__':
    parser = ArgumentParser("Upload experiment files to archive")
    parser.add_argument('submission_cfg', type=str, help="path to file describing submission")
    parser.add_argument('--label', type=str, default=None, help='Label for submission (defaults to date)')
    parser.add_argument('--key', type=str, default=None, help='RSA key for connecting to dcomp1')
    parser.add_argument('--user', type=str, default=None, help='User for connecting to dcomp1')

    args = parser.parse_args()

    if args.label:
        label = args.label
    else:
        label = datetime.now().strftime('%Y-%m-%d_%H-%M')

    run(args.submission_cfg, label, args.key, args.user)

    print("\nSuccess! If adding additional files to this same archive, use: --label {}".format(label))
