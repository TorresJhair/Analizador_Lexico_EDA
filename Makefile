CXX      := g++
CXXFLAGS := -std=c++17 -Wall -Wextra -Wpedantic -Iinclude
SOURCES  := src/token.cpp src/lexer.cpp

.PHONY: all clean

all: lexer

lexer: $(SOURCES) src/main.cpp
	$(CXX) $(CXXFLAGS) $^ -o $@

clean:
	rm -f lexer test_lexer test_token
