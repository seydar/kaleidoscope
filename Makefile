CC		= gcc
LFLAGS	= -fPIC

# from RLTK
all: libkaleidoscope.so

libkaleidoscope.so: kaleidoscope.c
	$(CC) $(LFLAGS) -c -o kaleidoscope.o $<
	$(CC) -shared -o libkaleidoscope.so kaleidoscope.o

.PHONY: clean
clean:
	rm -f kaleidoscope.o libkaleidoscope.so
