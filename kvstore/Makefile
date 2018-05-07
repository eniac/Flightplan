CC=gcc
CFLAGS=-Wall -g -lm -lpcap -lpthread
TARGET=cache
MAIN=kvcache.c

all: $(TARGET)

$(TARGET): memcache_forwarder.o
	$(CC) $(CFLAGS) $(MAIN) $^ -o $@

%.o: %.c %.h
	$(CC) $(CFLAGS) -c $< -o $@

.PHONY: clean

clean:
	rm -f *.o $(TARGET)
