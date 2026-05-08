CROSS_COMPILE?=
ASAN ?= false

CC = $(CROSS_COMPILE)gcc

GIT_VERSION ?= $(shell git describe --tags --abbrev=4 --dirty --always)

CFLAGS = -MMD -MP -O3 -g -march=native
CFLAGS += -DVERSION="\"$(GIT_VERSION)\""
CFLAGS += -std=gnu11
CFLAGS += -Wall -Wextra
CFLAGS += -Ilibldac/inc -Ilibldac/src
#CFLAGS += -DDEBUG
#CFLAGS += -DDEBUG_ADAPTATION
CFLAGS += -DDOUBLE64
LDLIBS = -lm

ifeq ($(ASAN),true)
LCFLAGS += -fsanitize=address
LDFLAGS += -fsanitize=address
endif

VPATH += libldac/src/
LDFLAGS += -L.

PREFIX ?= /usr/lib

all: libldacBT_dec.so

libldacBT_dec.so: LDFLAGS += -shared -fpic -Wl,-soname,libldacBT_dec.so.1
libldacBT_dec.so: CFLAGS += -fpic
libldacBT_dec.so: libldacdec.o bit_allocation.o huffCodes.o bit_reader.o utility.o imdct.o spectrum.o

mdct_imdct: LDLIBS += $(shell pkg-config sndfile --libs)
#mdct_imdct: CFLAGS += -DSINGLE_PRECISION
mdct_imdct: mdct_imdct.o ldaclib.o imdct.o

install: libldacBT_dec.so
	ln -sf libldacBT_dec.so libldacBT_dec.so.1
	cp -a libldacBT_dec.so libldacBT_dec.so.1 ${DESTDIR}${PREFIX}/
	cp libldacBT_dec.h {DESTDIR}${PREFIX}/include/ldac/libldacBT_dec.h
%.so:
	$(CC) $(LDFLAGS) -o $@ $^ $(LDLIBS)

.PHONY: clean
clean:
	rm -f *.d *.o ldacenc ldacdec libldacBT_dec.so libldacBT_dec.so.1

-include *.d


