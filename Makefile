DESTDIR=/usr/local

lib: av.rkt dns.rkt encrypt.rkt enums.rkt functions.rkt main.rkt
	raco make main.rkt

install: all
	mkdir -pv $(DESTDIR)/lib
	mkdir -pv $(DESTDIR)/share/racket/pkgs/libtoxcore-racket
	install -m 0755 libblight.so $(DESTDIR)/lib
	install -m 0644 *.rkt $(DESTDIR)/share/racket/pkgs/libtoxcore-racket
	install -m 0644 LICENSE $(DESTDIR)/share/racket/pkgs/libtoxcore-racket
	install -m 0644 fdl-1.3 $(DESTDIR)/share/racket/pkgs/libtoxcore-racket
	cp -Rv compiled $(DESTDIR)/share/racket/pkgs/libtoxcore-racket

link: install
	raco link -i $(DESTDIR)/share/racket/pkgs/libtoxcore-racket

clean:
	rm -Rv compiled/
