SUBDIRS = .

if !P4BOOSTERS_REPO_SET
$(error MUST set P4BOOSTERS_REPO at time of configuration)
endif

if !BUILD_FEC_BOOSTER
if !BUILD_MEMCACHED_BOOSTER
if !BUILD_COMPRESSION_BOOSTER
$(error MUST specify at least one of FEC_BOOSTER=true, MEMCACHED_BOOSTER=true COMPRESSION_BOOSTER=true at configuration)
endif
endif
endif

THRIFT_IDL = $(srcdir)/thrift/simple_switch.thrift

BOOSTER_INCLUDES=
BOOSTER_sources=booster_primitives.cpp
BOOSTER_ldadd=
BOOSTER_DEFINES=

if BUILD_FEC_BOOSTER
BOOSTER_INCLUDES+=\
	-I$(P4BOOSTERS_REPO)/RSECode \
	-I$(P4BOOSTERS_REPO)/FPGA/RSEVivadoHLS \
	-I./fecBoosters/
BOOSTER_sources+=fec_booster_primitives.cpp
BOOSTER_ldadd+=fecBoosters/fecBoosterP4lib.a
BOOSTER_DEFINES+=-DFEC_BOOSTER
endif

if BUILD_MEMCACHED_BOOSTER
BOOSTER_INCLUDES+=\
	-I$(P4BOOSTERS_REPO)/FPGA/MemcachedVivadoHLS \
	-I./memcachedBooster
BOOSTER_sources+=memcached_booster_primitives.cpp
BOOSTER_ldadd+=memcachedBooster/memcachedP4lib.a
BOOSTER_DEFINES+=-DMEMCACHED_BOOSTER
endif

if BUILD_COMPRESSION_BOOSTER
BOOSTER_INCLUDES+=\
	-I./compressionBoosters
BOOSTER_sources+=compression_booster_primitives.cpp compressionBoosters/vjCompression.cpp
BOOSTER_DEFINES+=-DCOMPRESSION_BOOSTER
endif

BOOSTER_sources+=sample_extern_object.cpp
BOOSTER_sources+=SenderSeqState.cpp
BOOSTER_sources+=ReceiverNakState.cpp

noinst_LTLIBRARIES = libsimpleswitch.la

libsimpleswitch_la_SOURCES = simple_switch.cpp simple_switch.h primitives.cpp $(BOOSTER_sources)

libsimpleswitch_la_LIBADD = \
$(top_builddir)/src/bm_sim/libbmsim.la \
$(top_builddir)/src/bf_lpm_trie/libbflpmtrie.la \
$(top_builddir)/src/BMI/libbmi.la \
$(top_builddir)/third_party/jsoncpp/libjson.la \
-lboost_system $(THRIFT_LIB) -lboost_program_options -lboost_filesystem


if COND_THRIFT

simple_switch_thrift_py_files = \
gen-py/sswitch_runtime/constants.py \
gen-py/sswitch_runtime/__init__.py \
gen-py/sswitch_runtime/SimpleSwitch.py \
gen-py/sswitch_runtime/ttypes.py
simple_switch_thrift_files = \
gen-cpp/bm/simple_switch_constants.cpp \
gen-cpp/bm/simple_switch_constants.h \
gen-cpp/bm/SimpleSwitch.cpp \
gen-cpp/bm/SimpleSwitch.h \
gen-cpp/bm/simple_switch_types.cpp \
gen-cpp/bm/simple_switch_types.h

BUILT_SOURCES = $(simple_switch_thrift_files) $(simple_switch_thrift_py_files)

sswitchpydir = $(pythondir)/sswitch_runtime
nodist_sswitchpy_PYTHON = $(simple_switch_thrift_py_files)

python_PYTHON = sswitch_CLI.py

# See
# http://www.gnu.org/software/autoconf/manual/autoconf-2.69/html_node/Installation-Directory-Variables.html
edit = sed \
	-e 's|@pythondir[@]|$(pythondir)|g'

simple_switch_CLI: Makefile
	rm -f $@ $@.tmp
	$(edit) $(srcdir)/$@.in >$@.tmp
	chmod +x $@.tmp
	chmod a-w $@.tmp
	mv $@.tmp $@

simple_switch_CLI: simple_switch_CLI.in

EXTRA_DIST = \
simple_switch_CLI.in \
sswitch_CLI

bin_SCRIPTS = \
simple_switch_CLI

AM_CPPFLAGS += \
-I$(srcdir)/thrift/src/ \
-I$(builddir)/gen-cpp \
$(BOOSTER_INCLUDES) \
$(BOOSTER_DEFINES)


libsimpleswitch_la_SOURCES += thrift/src/SimpleSwitch_server.cpp

bin_PROGRAMS = simple_switch

simple_switch_LDADD = \
$(top_builddir)/src/bm_runtime/libbmruntime.la \
$(top_builddir)/thrift_src/libruntimestubs.la \
libsimpleswitch.la \
libsimpleswitch_thrift.la  \
$(BOOSTER_ldadd)

simple_switch_SOURCES = main.cpp
# Must add these paths to rpath to be able to run with suid bit
simple_switch_LDFLAGS = -rpath `realpath -s ../../thrift_src/.libs/` -rpath `realpath -s ./.libs`
if ENABLE_MODULES
simple_switch_LDFLAGS += -rdynamic
endif

lib_LTLIBRARIES = libsimpleswitch_thrift.la

nodist_libsimpleswitch_thrift_la_SOURCES = \
$(simple_switch_thrift_files)

# See http://www.gnu.org/software/automake/manual/html_node/Multiple-Outputs.html

EXTRA_DIST += $(THRIFT_IDL)

# We copy the generated Python code to srcdir/ if we have permissions (i.e. not
# for 'make distcheck'). This is to ensure we can run the CLI easily. Maybe I
# will think of a better solution later.
thrift_files.ts: $(THRIFT_IDL)
	@rm -f thrift_files.tmp
	@touch thrift_files.tmp
	@mkdir -p $(builddir)/gen-cpp/bm
	$(THRIFT) -out $(builddir)/gen-cpp/bm --gen cpp -r $(THRIFT_IDL)
	$(THRIFT) -o $(builddir) --gen py -r $(THRIFT_IDL)
	if mkdir $(srcdir)/sswitch_runtime.test 2>/dev/null; then \
	  rm -rf $(srcdir)/sswitch_runtime/; \
	  cp -r $(builddir)/gen-py/sswitch_runtime/ $(srcdir)/; \
	  rm -rf $(srcdir)/sswitch_runtime.test; else :; \
        fi
	@mv -f thrift_files.tmp $@

$(BUILT_SOURCES): thrift_files.ts
## Recover from the removal of $@
	@if test -f $@; then :; else \
	  trap 'rm -rf thrift_files.lock thrift_files.ts' 1 2 13 15; \
## mkdir is a portable test-and-set
	if mkdir thrift_files.lock 2>/dev/null; then \
## This code is being executed by the first process.
	  rm -f thrift_files.ts; \
	  $(MAKE) $(AM_MAKEFLAGS) thrift_files.ts; \
	  result=$$?; rm -rf thrift_files.lock; exit $$result; \
	else \
## This code is being executed by the follower processes.
## Wait until the first process is done.
	  while test -d thrift_files.lock; do sleep 1; done; \
## Succeed if and only if the first process succeeded.
	    test -f thrift_files.ts; \
	  fi; \
	fi

nodist_pkginclude_HEADERS = \
gen-cpp/bm/simple_switch_constants.h \
gen-cpp/bm/SimpleSwitch.h \
gen-cpp/bm/simple_switch_types.h

CLEANFILES = $(BUILT_SOURCES) \
thrift_files.ts \
gen-cpp/bm/SimpleSwitch_server.skeleton.cpp \
$(bin_SCRIPTS)

# I used to do a rm on gen-cpp, but it was removing a .deps directory, instead I
# am adding the skeleton file to CLEANFILES
clean-local:
	rm -rf gen-py

endif  # COND_THRIFT
