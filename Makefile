src = $(wildcard src/*.c)
obj = $(src:.c=.o)
depfiles = $(obj:.o=.d)
lib_a = libimtk.a
bin = test

PREFIX = /usr/local

CC = gcc
AR = ar
CFLAGS = -std=gnu89 -pedantic -Wall -g -Isrc -I$(PREFIX)/include
LDFLAGS = -L$(PREFIX)/lib $(libgl) -lm

ifeq ($(shell uname -s), Darwin)
	CFLAGS += -DGL_SILENCE_DEPRECATION
	libgl = -framework OpenGL -framework GLUT
else
	libgl = -lGL -lGLU -lglut
endif

$(bin): $(lib_a) test.o
	$(CC) -o $@ test.o $(lib_a) $(LDFLAGS)

$(lib_a): $(obj)
	$(AR) rcs $@ $(obj)

-include $(depfiles)

%.d: %.c
	@$(CPP) $(CFLAGS) -MM -MT $(@:.d=.o) $< >$@

.PHONY: clean
clean:
	rm -f $(obj) $(bin) $(lib_a) test.o

.PHONY: cleandep
cleandep:
	rm -f $(depfiles)

.PHONY: install
install: $(lib_a)
	mkdir -p $(PREFIX)/include $(PREFIX)/lib
	cp $(lib_a) $(PREFIX)/lib/$(lib_a)
	cp src/imtk.h $(PREFIX)/include/imtk.h

.PHONY: uninstall
uninstall:
	rm -f $(PREFIX)/lib/$(lib_a)
	rm -f $(PREFIX)/include/imtk.h
