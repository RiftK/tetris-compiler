convert: lex.yy.c grammar.tab.c Makefile
	gcc -o convert lex.yy.c grammar.tab.c
grammar.tab.c: grammar.y
	bison -d grammar.y
lex.yy.c: scanner.l
	flex scanner.l
clean:
	rm -f grammar.tab.h convert lex.yy.c grammar.tab.c out1.py out2.py scanner
run: convert
	./convert < testin1.tetris > out1.py && ./convert < testin2.tetris > out2.py