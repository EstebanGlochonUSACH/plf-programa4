program_exe = calc
bison_file = parser.y
flex_file = lex.l

all: $(program_exe)

y.tab.c y.tab.h: $(bison_file)
	bison -dy $(bison_file)

lex.yy.c: $(flex_file) y.tab.h
	flex $(flex_file)

$(program_exe): lex.yy.c y.tab.c y.tab.h
	gcc -o $(program_exe) y.tab.c lex.yy.c

clean:
	rm $(program_exe) y.tab.c lex.yy.c y.tab.h y.output