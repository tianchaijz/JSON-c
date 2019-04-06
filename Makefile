CC= gcc
CCOPT= -O3 -std=c99 -Wall -pedantic -fomit-frame-pointer -Wall -DNDEBUG


all: checker libjsonchecker.so


checker: JSON_checker.c main.c
	$(CC) $(CCOPT) $^ -o $@

libjsonchecker.so: JSON_checker.c
	$(CC) $(CCOPT) -fPIC -shared $^ -o $@
