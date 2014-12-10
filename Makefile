###############################################################################
# Makefile
# Compiles Lex programs in C++
###############################################################################

SHELL = /bin/bash

BIN = .
SRC = $(wildcard *.lex)
EXE = C-indentator
OBJS = $(addsuffix .o, $(basename $(SRC)))

CFLAGS = -Wl,--no-as-needed
CXXFLAGS = $(CFLAGS) -std=c++0x
LDFLAGS = -ll -I/usr/include

###############################################################################

default: clean $(EXE)

$(BIN)/$(EXE): $(OBJS)
	$(CXX) -o $@ $^ $(LDFLAGS)

%.o: %.c
	$(CXX) -c -x c++ $(CXXFLAGS) $<

%.c: %.lex
	$(LEX) -o $@ $<

clean:
	$(RM) -fv $(EXE) core.* *~ *.o

###############################################################################
