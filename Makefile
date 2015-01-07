DESTDIR=/usr/local

libblight.so: blight.o
	gcc -shared -ltoxdns -o libblight.so blight.o

blight.o: blight.c
	gcc -Wall -fPIC -c blight.c

install: libblight.so
	mkdir -pv $(DESTDIR)/lib
	install -m 0755 libblight.so $(DESTDIR)/lib

clean:
	rm blight.o
