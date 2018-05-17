CC=gcc
CFLAGS=-g -lm -lpcap -lpthread
TARGET=cache
MAIN=kvcache.c

all: $(TARGET)

$(TARGET): memcache_forwarder.o memcache_parser.o
	$(CC) $(MAIN) $^ -o $@ $(CFLAGS)

%.o: %.c %.h
	$(CC) -c $< -o $@ $(CFLAGS)

.PHONY: clean

clean:
	rm -f *.o $(TARGET)
