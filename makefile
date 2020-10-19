# asm one don't work on AmigaOS4, we need to use VBCC (vasm)

#compiler=c/vasmm68k_mot
compiler=os4_cross_compiler_vasmm68k_mot

options=-m68020 

link=c/vlink

enable=.enable
disable=.disable

include makefile.cfg

inc=-Isdk31: -Indk31:includes/include_i

tests = open_window.exe	\

all:	${tests} 

clean:
		delete obj/#? #?.exe 

# compile tests

open_window.exe: open_window.s
		$(compiler) $(options) $(inc) -Fhunk -o obj/open_window.o open_window.s 
		$(link) -bamigahunk -o open_window.exe -s  obj/open_window.o


.PRECIOUS: %.hunk 

