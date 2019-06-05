#submission.py

This directory contains the experiment archive submission tool,
and a sample yml file to use alongside it.

### submission config
Passed as the first (and only required) argument to `submit.py`,
this should be a yaml file similar to `submission_template.yml`.

The file ** must ** contain an experiment field, containing an experiment
described in `requirements.yml`, and a `files` field, containing
a map of the files/directories to be uploaded and their locations.

It should also contain a `description` field, describing what is
being uploaded.

The example yaml file is:

```yaml
description: >-
    This is a description of an experiment which will
    subsequently be uploaded to the archive of all
    experiment data

experiment: memcached # Must match an experiment described in requirements.yml

repositories:
    P4Boosters: 7f4905bf # Revision of repo from which code was used

files: # These files will be uploaded to the archive
    documentation.md: ../memcached/Memcached.md
    data: ../memcached/output/
    analysis: ../memcached/analysis/
    bitstream.tar.gz: /home/iped/1104bit.tar.gz
```

### requirements.yml
This file, which shouldn't have to be frequently edited,
describes the fields which are necessary for each
type of experiment submission.

Note that additional files/fields can always be included, this
just provides a sanity check that you are not forgetting
an important file.

The initial state of `requirements.yml` is :
```yaml
all:
    - description
    - experiment
    - repositories:
        - P4Boosters
    - files:
        - documentation.md

memcached:
    - files:
        - data
        - bitstream.tar.gz
```

This ensures that every submission defines a description, experiment,
and the P4Boosters repository revision number, as well
as a documentation file.

The memcached experiment must in addition provide data and a bitstream.
