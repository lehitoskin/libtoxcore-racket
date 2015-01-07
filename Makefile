DESTDIR=/usr/local
CFLAGS="-Itox/include"
LD_FLAGS="-Ltox/include/"

libblight.so: blight.o
	gcc $(CFLAGS) $(LD_FLAGS) -shared -fPIC -ltoxdns -o libblight.so blight.o

blight.o: blight.c
	gcc -Wall -fPIC -c blight.c

install: libblight.so
	mkdir -pv $(DESTDIR)/lib
	install -m 0755 libblight.so $(DESTDIR)/lib

clean:
	rm blight.o
