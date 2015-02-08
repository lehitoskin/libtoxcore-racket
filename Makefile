DESTDIR=/usr/local

all: libblight.so lib

libblight.so: blight.o
	gcc -shared -Wl,-soname=blight -ltoxdns -lopenal -o libblight.so blight.o

blight.o: blight.c
	gcc -Wall -fPIC -std=c99 -c blight.c

lib: av.rkt blight.rkt dns.rkt encrypt.rkt enums.rkt functions.rkt main.rkt
	raco make main.rkt

install: libblight.so lib
	mkdir -pv $(DESTDIR)/lib
	mkdir -pv $(DESTDIR)/share/racket/pkgs/libtoxcore-racket
	install -m 0755 libblight.so $(DESTDIR)/lib
	install -m 0644 *.rkt $(DESTDIR)/share/racket/pkgs/libtoxcore-racket
	cp -Rv compiled $(DESTDIR)/share/racket/pkgs/libtoxcore-racket
	raco link -i $(DESTDIR)/share/racket/pkgs/libtoxcore-racket

clean: blight.o compiled
	rm -v blight.o
	rm -Rv compiled/

debug: blight.o
	gcc -D DEBUG -shared -Wl,-soname=blight -ltoxdns -lopenal -o libblight.so blight.o
